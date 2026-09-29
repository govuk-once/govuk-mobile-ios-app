import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class TravelAlertsPermissionViewSnapshotTests: SnapshotTestCase {
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

    func test_loadInNavigationController_withoutImage_light_rendersCorrectly() {
        let viewModel = makeViewModel(showImage: false)
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_withoutImage_dark_rendersCorrectly() {
        let viewModel = makeViewModel(showImage: false)
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_loading_light_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .success(())
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = makeViewModel(travelService: mockTravelService, showImage: true)
        let viewController = makeViewController(viewModel: viewModel)

        viewModel.notNowAction()
        await Task.yield()

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_loading_dark_rendersCorrectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .success(())
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = makeViewModel(travelService: mockTravelService, showImage: true)
        let viewController = makeViewController(viewModel: viewModel)

        viewModel.notNowAction()
        await Task.yield()

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewModel(
        travelService: TravelServiceInterface? = nil,
        showImage: Bool = true
    ) -> TravelAlertsPermissionViewModel {
        let testCountry = Country(
            name: "France",
            slug: "france",
            rawLastUpdate: "",
            synonyms: []
        )
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: travelService ?? MockTravelService(),
            notificationService: MockNotificationService(),
            analyticsService: MockAnalyticsService(),
            urlOpener: MockURLOpener(),
            showImage: showImage,
            country: testCountry,
            dismissSheetAction: { /*EmptyForTests*/ },
            openURLAction: { _ in /*EmptyForTests*/ },
            dismissAfterSuccessAction: { /*EmptyForTests*/ },
            dismissAfterErrorAction: { /*EmptyForTests*/ }
        )
        NotificationCenter.default.removeObserver(viewModel)
        return viewModel
    }

    private func makeViewController(viewModel: TravelAlertsPermissionViewModel) -> UIViewController {
        let view = TravelAlertsPermissionView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceFullscreen
        return viewController
    }
}
