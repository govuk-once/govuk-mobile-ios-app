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

    private func makeViewModel(
        showImage: Bool = true
    ) -> TravelAlertsPermissionViewModel {
        let testCountry = Country(
            slug: "france",
            name: "France",
            synonyms: [],
            updatedAt: nil,
            id: "1"
        )
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: MockTravelService(),
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
