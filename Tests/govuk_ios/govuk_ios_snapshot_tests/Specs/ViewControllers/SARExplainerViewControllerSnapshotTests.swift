import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class SARExplainerViewControllerSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        let viewModel = SARExplainerViewModel(
            analyticsService: MockAnalyticsService(),
            sarAction: { }
        )
        let sarExplainerView = SARExplainerView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: sarExplainerView,
            statusBarStyle: .darkContent
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let viewModel = SARExplainerViewModel(
            analyticsService: MockAnalyticsService(),
            sarAction: { }
        )
        let sarExplainerView = SARExplainerView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: sarExplainerView,
            statusBarStyle: .darkContent
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }
}
