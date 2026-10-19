import UIKit
import SwiftUI

final class VehicleCheckCoordinatorStateDriven: BaseCoordinator {
    struct PlaceHolderResults: Equatable {
        let searchTerm: String
        let results: [String]
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
                self?.navigationController.dismiss(animated: true)
            } else {
                self?.dismissFlow()
            }
        }

        let hostingController = UIHostingController(rootView: inputView)
        let navController = UINavigationController(rootViewController: hostingController)

        let target = isNested ? (navigationController.presentedViewController ?? navigationController) : navigationController
        target.present(navController, animated: true)
    }

    private func showResultsView(data: PlaceHolderResults) {
        let resultsView = ResultsView(data: data) { [weak self] in
            self?.dismissFlow()
        } onSearch: { [weak self] in
            self?.state = .nestedInput
        }

        let hostingController = UIHostingController(rootView: resultsView)
        let target = navigationController.presentedViewController as? UINavigationController ?? navigationController

        let sheetNavController = UINavigationController(rootViewController: hostingController)
        target.present(sheetNavController, animated: true)
    }

    private func dismissFlow() {
        dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}

