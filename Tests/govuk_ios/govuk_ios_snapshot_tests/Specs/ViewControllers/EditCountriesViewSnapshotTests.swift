import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class EditCountriesViewSnapshotTests: SnapshotTestCase {

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
                TravelGroup(namespace: "travel", group: "france", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "instant")
            ]),
            countryListResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: [])
            ])
        ))

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

    func test_loadInNavigationController_loaded_dark_rendersCorrectly() async {
        let viewModel = makeViewModel(travelService: SnapshotTravelService(
            travelGroupResult: .success([
                TravelGroup(namespace: "travel", group: "france", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "germany", subgroup: "instant"),
                TravelGroup(namespace: "travel", group: "spain", subgroup: "instant")
            ]),
            countryListResult: .success([
                Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: []),
                Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00.000Z", synonyms: [])
            ])
        ))

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

    func test_loadInNavigationController_error_generic_light_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let viewModel = makeViewModel(travelService: mockTravelService)

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

    func test_loadInNavigationController_error_generic_dark_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let viewModel = makeViewModel(travelService: mockTravelService)

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

    func test_loadInNavigationController_error_network_light_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.networkUnavailable)
        let viewModel = makeViewModel(travelService: mockTravelService)

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

    func test_loadInNavigationController_error_network_dark_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.networkUnavailable)
        let viewModel = makeViewModel(travelService: mockTravelService)

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
            notificationService: notificationService,
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: { /*NO-OP*/ },
            navigateBackAction: { /*NO-OP*/ }
        )
    }

    private func makeViewController(viewModel: EditCountriesViewModel) -> UIViewController {
        let view = EditCountriesView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceBackground
        return viewController
    }
}
