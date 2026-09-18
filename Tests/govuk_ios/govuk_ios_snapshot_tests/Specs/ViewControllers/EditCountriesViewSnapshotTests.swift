import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class EditCountriesViewSnapshotTests: SnapshotTestCase {
    var coreData: CoreDataRepository!

    func test_loadInNavigationController_loading_light_rendersCorrectly() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_loading_dark_rendersCorrectly() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_loaded_light_rendersCorrectly() async {
        let viewModel = makeViewModel(travelService: SnapshotTravelService(
            travelGroupResult: .success([
                TravelGroup(namespace: "travel", group: "france", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "daily")
            ]),
            countryListResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: [])
            ])
        ))

        await viewModel.viewDidAppear()
        await Task.yield()
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_loaded_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(travelService: SnapshotTravelService(
            travelGroupResult: .success([
                TravelGroup(namespace: "travel", group: "france", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "daily"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "daily")
            ]),
            countryListResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: [])
            ])
        ))

        await viewModel.viewDidAppear()
        await Task.yield()
        // Wait for all async tasks to complete
        try? await Task.sleep(for: .seconds(1))

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_error_light_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .failure(.apiUnavailable)
        let viewModel = makeViewModel(travelService: mockTravelService)

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_error_dark_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .failure(.apiUnavailable)
        let viewModel = makeViewModel()

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewModel(travelService: TravelServiceInterface? = nil) -> EditCountriesViewModel {
        let defaultTravelService = SnapshotTravelService(
            travelGroupResult: nil,
            countryListResult: nil
        )
        let mockTravelService = travelService ?? defaultTravelService
        let analyticsService = MockAnalyticsService()
        let notificationService = MockNotificationService()
        return EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: analyticsService,
            notificationService: notificationService
        )
    }

    private func makeViewController(viewModel: EditCountriesViewModel) -> UIViewController {
        let view = EditCountriesView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceBackground
        return viewController
    }
}
