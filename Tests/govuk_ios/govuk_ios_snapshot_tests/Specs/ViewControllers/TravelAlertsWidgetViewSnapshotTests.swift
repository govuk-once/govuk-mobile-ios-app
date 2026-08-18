import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class TravelAlertsWidgetViewSnapshotTests: SnapshotTestCase {
    func test_loading_light_rendersCorrectly() {
        let viewModel = makeViewModel(result: nil)
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loading_dark_rendersCorrectly() {
        let viewModel = makeViewModel(result: nil)
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loaded_light_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
            ])
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loaded_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
            ])
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_error_light_rendersCorrectly() async {
        let viewModel = makeViewModel(result: .failure(.apiUnavailable))

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_error_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(result: .failure(.apiUnavailable))

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewModel(result: TravelGroupResult?) -> TravelAlertsWidgetViewModel {
        let travelService = SnapshotTravelService(result: result)
        return TravelAlertsWidgetViewModel(
            travelService: travelService,
            analyticsService: MockAnalyticsService()
        )
    }

    private func makeViewController(viewModel: TravelAlertsWidgetViewModel) -> UIViewController {
        let view = TravelAlertsWidgetView(viewModel: viewModel)
            .frame(height: 90)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceBackground
        return viewController
    }
}

private final class SnapshotTravelService: TravelServiceInterface {
    private let result: TravelGroupResult?

    init(result: TravelGroupResult?) {
        self.result = result
    }

    func getGroups(forceRefresh: Bool, completion: @escaping TravelGroupResultCompletion) {
        guard let result else { return }
        completion(result)
    }

    func invalidateCache() {}
}
