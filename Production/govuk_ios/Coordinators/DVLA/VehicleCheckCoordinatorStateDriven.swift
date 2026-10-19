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

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         urlOpener: URLOpener) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.configService = configService
        self.urlOpener = urlOpener
        super.init(navigationController: navigationController)
    }


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

    private func showInputView(isNested: Bool) {
        let inputView = PlaceholderView { [weak self] searchTerm, results in
            let placeholderResults = PlaceHolderResults(searchTerm: searchTerm, results: results)
            self?.state = .results(data: placeholderResults)
        } onCancel: { [weak self] in
            if isNested {
                self?.rootNavCon.presentedViewController?.dismiss(animated: true)
            } else {
                self?.dismissFlow()
            }
        }

        let hostingController = UIHostingController(rootView: inputView)

        if isNested {
            let navController = UINavigationController(rootViewController: hostingController)
            let target = rootNavCon.presentedViewController ?? rootNavCon
            target.present(navController, animated: true)
        } else {
            hostingController.view.backgroundColor = .clear
            rootNavCon.view.backgroundColor = .clear
            rootNavCon.modalTransitionStyle = .crossDissolve
            set(hostingController)
        }
    }

    private func showResultsView(data: PlaceHolderResults) {
        let resultsView = PlaceholderSearchResultsView(data: data) { [weak self] in
            self?.dismissFlow()
        } searchAction: { [weak self] in
            self?.state = .nestedInput
        }

        let hostingController = UIHostingController(rootView: resultsView)
        let presentedNavigationCon = rootNavCon.presentedViewController
        as? UINavigationController
        let target =  presentedNavigationCon ?? rootNavCon

        let sheetNavController = UINavigationController(rootViewController: hostingController)
        target.present(sheetNavController, animated: true)
    }

    private func dismissFlow() {
        rootNavCon.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
