import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class FollowCountryViewSnapshotTests: SnapshotTestCase {
    var coreData: CoreDataRepository!

    func test_loadInNavigationController_light_rendersCorrectly() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_loaded_light_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: []),
            Country(country: "Belgium", slug: "belgium", lastUpdate: "", synonyms: []),
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: [])
        ])
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

    func test_loadInNavigationController_loaded_dark_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: []),
            Country(country: "Belgium", slug: "belgium", lastUpdate: "", synonyms: []),
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: [])
        ])
        let viewModel = makeViewModel(travelService: mockTravelService)

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_empty_light_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([])
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

    func test_loadInNavigationController_empty_dark_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([])
        let viewModel = makeViewModel(travelService: mockTravelService)

        await viewModel.viewDidAppear()
        await Task.yield()

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
        let viewModel = makeViewModel(travelService: mockTravelService)

        await viewModel.viewDidAppear()
        await Task.yield()

        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewModel(travelService: TravelServiceInterface? = nil) -> FollowCountryViewModel {
        let mockTravelService = travelService ?? MockTravelService()
        let analyticsService = MockAnalyticsService()
        return FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: analyticsService,
            countrySelectedAction: { _ in /*Empty for tests*/},
            dismissAction: { /*Empty For Tests*/ }
        )
    }

    private func makeViewController(viewModel: FollowCountryViewModel) -> UIViewController {
        let view = FollowCountryView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}
