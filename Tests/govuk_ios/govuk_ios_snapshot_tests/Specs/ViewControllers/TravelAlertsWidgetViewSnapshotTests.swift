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
                TravelGroup(namespace: "travel", group: "france", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "daily")
            ]),
            countriesResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: [])
            ])
        )

        await viewModel.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

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
                TravelGroup(namespace: "travel", group: "france", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "daily")
            ]),
            countriesResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: [])
            ])
        )

        await viewModel.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

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
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

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
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_empty_light_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
            ]),
            countriesResult: .success([])
        )

        await viewModel.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_empty_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(
            result: .success([
                TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
            ]),
            countriesResult: .success([])
        )

        await viewModel.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewModel(result: TravelGroupResult?, countriesResult: CountriesListResult? = nil) -> TravelAlertsWidgetViewModel {
        let travelService = SnapshotTravelService(
            travelGroupResult: result,
            countryListResult: countriesResult
        )
        return TravelAlertsWidgetViewModel(
            travelService: travelService,
            analyticsService: MockAnalyticsService(),
            linkAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            openURLAction: { _ in /*EmptyForTests*/ }
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

    private let travelGroupResult: TravelGroupResult?
    private let countryListResult: CountriesListResult?

    init(
        travelGroupResult: TravelGroupResult?,
        countryListResult: CountriesListResult? = nil
    ) {
        self.travelGroupResult = travelGroupResult
        self.countryListResult = countryListResult
    }

    func getGroups(forceRefresh: Bool, completion: @escaping TravelGroupResultCompletion) {
        guard let travelGroupResult else { return }
        completion(travelGroupResult)
    }

    func getCountries(forceRefresh: Bool, completion: @escaping CountriesListResultCompletion) {
        if let countryListResult = countryListResult {
            completion(countryListResult)
        } else {
            completion(.success([]))
        }
    }

    func invalidateCache() {}
}
