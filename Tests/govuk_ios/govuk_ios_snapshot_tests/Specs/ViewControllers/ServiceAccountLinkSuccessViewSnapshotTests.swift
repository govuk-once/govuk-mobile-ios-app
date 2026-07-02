import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class ServiceAccountLinkSuccessViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let viewModel = ServiceAccountLinkSuccessViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {}
        )
        let view = ServiceAccountLinkSuccessView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        return viewController
    }
}
