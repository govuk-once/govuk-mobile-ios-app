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
        showImage: Bool = true,
        title: String = "Give permission",
        body: String = "We need your permission to send notifications and collect app usage statistics.",
        primaryButtonTitle: String = "Agree and continue",
        secondaryButtonTitle: String = "Not now"
    ) -> TravelAlertsPermissionViewModel {
        TravelAlertsPermissionViewModel(
            analyticsService: MockAnalyticsService(),
            showImage: showImage,
            title: title,
            body: body,
            primaryButtonTitle: primaryButtonTitle,
            secondaryButtonTitle: secondaryButtonTitle,
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )
    }

    private func makeViewController(viewModel: TravelAlertsPermissionViewModel) -> UIViewController {
        let view = TravelAlertsPermissionView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceFullscreen
        return viewController
    }
}
