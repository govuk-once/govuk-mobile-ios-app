import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class YourAccountsViewSnapshotTests: SnapshotTestCase {

    func test_loadInNavigationController_success_light_rendersCorrectly() {

        let viewModel = YourAccountsSettingsViewModel(
            userService: MockUserService(),
            dismissAction: {}
        )

        viewModel.state = .success

        let view = YourAccountsView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_success_dark_rendersCorrectly() {

        let viewModel = YourAccountsSettingsViewModel(
            userService: MockUserService(),
            dismissAction: {}
        )

        viewModel.state = .success

        let view = YourAccountsView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_failure_light_rendersCorrectly() {
        let viewModel = YourAccountsSettingsViewModel(
            userService: MockUserService(),
            dismissAction: {}
        )

        viewModel.state = .failure

        let view = YourAccountsView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_failure_dark_rendersCorrectly() {

        let viewModel = YourAccountsSettingsViewModel(
            userService: MockUserService(),
            dismissAction: {}
        )

        viewModel.state = .failure

        let view = YourAccountsView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let viewModel = YourAccountsSettingsViewModel(
            userService: MockUserService(),
            dismissAction: {}
        )
        let view = YourAccountsView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}


