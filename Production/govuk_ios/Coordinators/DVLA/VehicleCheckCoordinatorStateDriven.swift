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
            showInputView(isNested: false)
        case .results(let data):
            showResultsView(data: data)
        case .nestedInput:
            showInputView(isNested: true)
        }
    }

    // MARK: - UI Presentation Logic

    private func topmostPresentedVC() -> UIViewController? {
        var viewController: UIViewController? = bottomSheet
        while let next = viewController?.presentedViewController {
            viewController = next
        }
        return viewController
    }

    private func showInputView(isNested: Bool) {
        let inputView = PlaceholderView { [weak self] searchTerm, results in
            let placeholderResults = PlaceHolderResults(searchTerm: searchTerm, results: results)
            self?.state = .results(data: placeholderResults)
        } onCancel: { [weak self] in
            if isNested {
                self?.topmostPresentedVC()?.dismiss(animated: true)
            } else {
                self?.dismissFlow()
            }
        }

        let hostingController = UIHostingController(rootView: inputView)
        hostingController.view.backgroundColor = .clear

        if isNested {
            let navController = UINavigationController(rootViewController: hostingController)
            navController.modalPresentationStyle = .overCurrentContext
            navController.modalTransitionStyle = .crossDissolve
            navController.view.backgroundColor = .clear
            topmostPresentedVC()?.present(navController, animated: true)
        } else {
            rootNavCon.view.backgroundColor = .clear
            rootNavCon.setNavigationBarHidden(true, animated: false)
            rootNavCon.modalTransitionStyle = .crossDissolve
            set(hostingController)
        }
    }

    private func showResultsView(data: PlaceHolderResults) {
        let resultsView = PlaceholderSearchResultsView(data: data) { [weak self] in
            self?.handleClose()
        } searchAction: { [weak self] in
            self?.state = .nestedInput
        }

        let hostingController = UIHostingController(rootView: resultsView)
        let newSheet = UINavigationController(rootViewController: hostingController)

        if bottomSheet != nil {
            guard let topVC = topmostPresentedVC() else { return }
            let hostSheet = topVC.presentingViewController ?? topVC
            newSheet.presentationController?.delegate = self
            topVC.dismiss(animated: false) { [weak self] in
                guard self != nil else { return }
                hostSheet.present(newSheet, animated: true)
            }
        } else {
            newSheet.presentationController?.delegate = self
            guard let presenter = rootNavCon.presentingViewController else {
                assertionFailure(
                    "rootNavCon has no presentingViewController — cannot present results"
                )
                return
            }
            rootNavCon.dismiss(animated: false) { [weak self] in
                presenter.present(newSheet, animated: true)
                self?.bottomSheet = newSheet
            }
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

    private func dismissTopmostSheet() {
        guard let topVC = topmostPresentedVC(),
              topVC !== bottomSheet else {
            dismissFlow()
            return
        }
        topVC.dismiss(animated: true)
    }

    override func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        if bottomSheet == nil {
            finish()
        } else if presentationController.presentedViewController === bottomSheet {
            bottomSheet = nil
            finish()
        }
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
