import UIKit
import SwiftUI
import GovKit

struct PlaceHolderResults: Equatable {
    let searchTerm: String
    let results: [String]
}

// final class VehicleCheckCoordinatorStateDriven: BaseCoordinator {
final class VehicleCheckCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let urlOpener: URLOpener

    private weak var bottomSheet: UINavigationController?

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         urlOpener: URLOpener,
         closeBehaviour: CloseBehaviour = .dismissTopmost) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.configService = configService
        self.urlOpener = urlOpener
        self.closeBehaviour = closeBehaviour
        super.init(navigationController: navigationController)
    }

    enum CloseBehaviour {
        case dismissAll
        case dismissTopmost
    }

    private let closeBehaviour: CloseBehaviour

    enum FlowState: Equatable {
        case initialInput
        case results(data: PlaceHolderResults)
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
        case .results(let data):
            showResultsView(data: data)
        case .nestedInput:
            showNestedInput()
        }
    }

    // MARK: - View Construction

    private func makeInputView(onCancel: @escaping () -> Void) -> PlaceholderView {
        PlaceholderView { [weak self] searchTerm, results in
            let placeholderResults = PlaceHolderResults(searchTerm: searchTerm, results: results)
            self?.state = .results(data: placeholderResults)
        } onCancel: { onCancel() }
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
        // rootNavCon is .overCurrentContext — make it fully transparent so
        // the PlaceholderView's semi-transparent backdrop shows through
        rootNavCon.view.backgroundColor = .clear
        rootNavCon.setNavigationBarHidden(true, animated: false)
        rootNavCon.modalTransitionStyle = .crossDissolve
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

    private func showResultsView(data: PlaceHolderResults) {
        let resultsView = PlaceholderSearchResultsView(data: data) { [weak self] in
            self?.handleClose()
        } searchAction: { [weak self] in
            self?.state = .nestedInput
        }

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
        // dismiss rootNavCon and present from its parent instead
        guard let presenter = rootNavCon.presentingViewController else {
            assertionFailure(
                "rootNavCon has no presentingViewController — cannot present results"
            )
            return
        }
        rootNavCon.dismiss(animated: false) { [weak self] in
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

    private func dismissFlow() {
        if let sheet = bottomSheet,
           let presenter = sheet.presentingViewController {
            presenter.dismiss(animated: true) { [weak self] in
                self?.bottomSheet = nil
                self?.finish()
            }
        } else {
            rootNavCon.dismiss(animated: true) { [weak self] in
                self?.finish()
            }
        }
    }
}
