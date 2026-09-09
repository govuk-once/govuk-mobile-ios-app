import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class LocalAuthorityExplainerViewSnapshotTests: SnapshotTestCase {

    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
        )
    }

    private func viewController() -> UIViewController {
        let viewModel = LocalAuthorityExplainerViewModel(
            analyticsService: MockAnalyticsService(),
            navigateToPostcodeEntry: {},
            dismissAction: {}
        )
        let view = LocalAuthorityExplainerView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}

