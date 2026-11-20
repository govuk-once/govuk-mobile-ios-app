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
                TravelGroup(namespace: "travel", group: "france", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "instant")
            ]),
            countriesResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: [])
            ])
        )

        let viewController = makeViewController(viewModel: viewModel)

        await VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        ) {
            if case .loaded = viewModel.viewState { return true }
            return false
        }
    }

    func test_loaded_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel", group: "france", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "instant")
            ]),
            countriesResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: [])
            ])
        )

        let viewController = makeViewController(viewModel: viewModel)

        await VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        ) {
            if case .loaded = viewModel.viewState { return true }
            return false
        }
    }

    func test_error_light_rendersCorrectly() async {
        let viewModel = makeViewModel(result: .failure(.apiUnavailable))

        let viewController = makeViewController(viewModel: viewModel)

        await VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        ) {
            if case .error = viewModel.viewState { return true }
            return false
        }
    }

    func test_error_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(result: .failure(.apiUnavailable))

        let viewController = makeViewController(viewModel: viewModel)

        await VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        ) {
            if case .error = viewModel.viewState { return true }
            return false
        }
    }

    func test_empty_light_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
            ]),
            countriesResult: .success([])
        )

        let viewController = makeViewController(viewModel: viewModel)

        await VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        ) {
            if case .empty = viewModel.viewState { return true }
            return false
        }
    }

    func test_empty_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
            ]),
            countriesResult: .success([])
        )

        let viewController = makeViewController(viewModel: viewModel)

        await VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        ) {
            if case .empty = viewModel.viewState { return true }
            return false
        }
    }

    private func makeViewModel(result: TravelGroupResult?, countriesResult: CountriesListResult? = nil) -> TravelAlertsWidgetViewModel {
        let travelService = SnapshotTravelService(
            travelGroupResult: result,
            countryListResult: countriesResult
        )
        return TravelAlertsWidgetViewModel(
            travelService: travelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            feedbackURL: URL("www.example.com/feedback")!,
            urlOpener: MockURLOpener(),
            dismissAction: { /*EmptyForTests*/ },
            editAction: { /*EmptyForTests*/ },
            openURLAction: { _ in /*EmptyForTests*/ }
        )
    }

    private func makeViewController(viewModel: TravelAlertsWidgetViewModel) -> UIViewController {
        let view = TravelAlertsWidgetView(viewModel: viewModel)
            .frame(maxHeight: 240)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceBackground
        return viewController
    }
}
