import UIKit
import SwiftUI
import GovKit

// final class VehicleCheckCoordinatorStateDriven: BaseCoordinator {
final class VehicleCheckCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let urlOpener: URLOpener
    private let dvlaService: DVLAServiceInterface

    private weak var bottomSheet: UINavigationController?

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         urlOpener: URLOpener,
         dvlaService: DVLAServiceInterface,
         closeBehaviour: CloseBehaviour = .dismissTopmost) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.configService = configService
        self.urlOpener = urlOpener
        self.dvlaService = dvlaService
        self.closeBehaviour = closeBehaviour
        super.init(navigationController: navigationController)
    }

    enum CloseBehaviour {
        case dismissAll
        case dismissTopmost
    }

    private let closeBehaviour: CloseBehaviour

    enum FlowState {
        case initialInput
        case results(vehicle: VehicleEnquiryResponse.Vehicle)
        case nestedInput
    }

    private var state: FlowState = .initialInput {
        didSet { handleStateTransition(to: state) }
    }

    override func start(url: URL?) {
        state = .initialInput
    }

    private func handleStateTransition(to newState: FlowState) {
        switch newState {
        case .initialInput:
            showInitialInput()
        case .results(let vehicle):
            showResultsView(vehicle: vehicle)
        case .nestedInput:
            showNestedInput()
        }
    }

    // MARK: - View Construction

    private func makeInputView(onCancel: @escaping () -> Void) -> RegistrationNumberFormModal {
        let submitAction: PlateSubmitAction = { [weak self] plate in
            guard let self else { return .failure(.serviceUnavailable) }
            
            let result = await self.dvlaService.fetchVehicle(registration: plate)
            switch result {
            case .success(let response):
                return .success(response.vehicle)
            case .failure(let error):
                switch error {
                case .notFound:
                    return .failure(.notFound)
                default:
                    return .failure(.serviceUnavailable)
                }
            }
        }

        let viewModel = PlateFormViewModel(submitAction: submitAction)

        return RegistrationNumberFormModal(
            viewModel: viewModel,
            onCancel: onCancel
        ) { [weak self] vehicle in
            self?.state = .results(vehicle: vehicle)
        }
    }

    // MARK: - UI Presentation Logic

    private func topmostPresentedVC() -> UIViewController? {
        var current: UIViewController? = bottomSheet
        while let next = current?.presentedViewController {
            current = next
        }
        return current
    }

    private func showInitialInput() {
        let inputView = makeInputView { [weak self] in self?.dismissFlow() }
        let hostingController = UIHostingController(rootView: inputView)
        hostingController.view.backgroundColor = .clear
        // root is .overCurrentContext — make it fully transparent so
        // the backdrop shows through to the content behind
        root.view.backgroundColor = .clear
        root.setNavigationBarHidden(true, animated: false)
        root.modalTransitionStyle = .crossDissolve
        set(hostingController)
    }

    private func showNestedInput() {
        let inputView = makeInputView { [weak self] in
            self?.topmostPresentedVC()?.dismiss(animated: true)
        }
        let hostingController = UIHostingController(rootView: inputView)
        hostingController.view.backgroundColor = .clear
        let navController = UINavigationController(rootViewController: hostingController)
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        navController.view.backgroundColor = .clear
        topmostPresentedVC()?.present(navController, animated: true)
    }

    private func showResultsView(vehicle: VehicleEnquiryResponse.Vehicle) {
        let actions = VehicleCheckResultActions(
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            searchAction: { [weak self] in
                self?.state = .nestedInput
            },
            dismissAction: { [weak self] in
                self?.handleClose()
            }
        )
        let viewModel = VehicleCheckResultViewModel(
            vehicle: vehicle,
            analyticsService: analyticsService,
            configService: configService,
            actions: actions
        )
        let resultsView = VehicleCheckResultView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: resultsView)
        let newSheet = UINavigationController(rootViewController: hostingController)
        newSheet.presentationController?.delegate = self

        let isFirstPresentation = bottomSheet == nil
        if isFirstPresentation {
            presentAsFirstSheet(newSheet)
        } else {
            presentAsStackedSheet(newSheet)
        }
    }

    private func presentAsFirstSheet(_ sheet: UINavigationController) {
        // .overCurrentContext breaks presentedViewController tracking —
        // dismiss root (NavCon) and present from its parent instead
        guard let presenter = root.presentingViewController else {
            assertionFailure(
                "root has no presentingViewController — cannot present results"
            )
            return
        }
        root.dismiss(animated: false) { [weak self] in
            presenter.present(sheet, animated: true)
            self?.bottomSheet = sheet
        }
    }

    private func presentAsStackedSheet(_ sheet: UINavigationController) {
        guard let vcToDismiss = topmostPresentedVC() else { return }
        let presentingSheet = vcToDismiss.presentingViewController ?? vcToDismiss
        vcToDismiss.dismiss(animated: false) { [weak self] in
            guard self != nil else { return }
            presentingSheet.present(sheet, animated: true)
        }
    }

    // MARK: - Dismissal

    private func handleClose() {
        switch closeBehaviour {
        case .dismissAll:
            dismissFlow()
        case .dismissTopmost:
            dismissTopmostSheet()
        }
    }

    /// Peels off the topmost stacked sheet, or dismisses the entire flow if only one remains.
    private func dismissTopmostSheet() {
        guard let topVC = topmostPresentedVC() else {
            dismissFlow()
            return
        }
        let isOnlySheet = topVC === bottomSheet
        if isOnlySheet {
            dismissFlow()
        } else {
            topVC.dismiss(animated: true)
        }
    }

    override func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        let dismissedVC = presentationController.presentedViewController
        let isInitialInputDismissed = bottomSheet == nil
        let isBottomSheetDismissed = dismissedVC === bottomSheet

        if isInitialInputDismissed || isBottomSheetDismissed {
            bottomSheet = nil
            finish()
        }
        // Stacked sheet swiped away: coordinator stays alive,
        // underlying sheets remain interactive
    }

    /// Tears down the entire flow — all sheets and the initial overlay.
    private func dismissFlow() {
        if let sheet = bottomSheet,
           let presenter = sheet.presentingViewController {
            // Sheets are on screen: dismiss the bottom sheet from its
            // presenter, which tears down the entire stacked chain
            presenter.dismiss(animated: true) { [weak self] in
                self?.bottomSheet = nil
                self?.finish()
            }
        } else {
            // Only the initial input overlay is on screen
            root.dismiss(animated: true) { [weak self] in
                self?.finish()
            }
        }
    }
}
