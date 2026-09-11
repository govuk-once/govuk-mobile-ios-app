import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class CountryListViewSnapshotTests: SnapshotTestCase {
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
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: []),
            Country(name: "Belgium", slug: "belgium", rawLastUpdate: "", synonyms: []),
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: [])
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
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: []),
            Country(name: "Belgium", slug: "belgium", rawLastUpdate: "", synonyms: []),
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: [])
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

    private func makeViewModel(travelService: TravelServiceInterface? = nil) -> CountryListViewModel {
        let mockTravelService = travelService ?? MockTravelService()
        let analyticsService = MockAnalyticsService()
        return CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: analyticsService,
            countrySelectedAction: { _ in /*Empty for tests*/},
            dismissAction: { /*Empty For Tests*/ }
        )
    }

    private func makeViewController(viewModel: CountryListViewModel) -> UIViewController {
        let view = CountryListView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}
