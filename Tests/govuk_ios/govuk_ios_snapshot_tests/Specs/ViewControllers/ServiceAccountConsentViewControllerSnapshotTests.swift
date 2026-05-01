import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class ServiceAccountConsentViewControllerSnapshotTests: SnapshotTestCase {
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
        let viewModel = ServiceAccountConsentViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {},
            cancelAction: {}
        )
        let view = ServiceAccountConsentView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}

