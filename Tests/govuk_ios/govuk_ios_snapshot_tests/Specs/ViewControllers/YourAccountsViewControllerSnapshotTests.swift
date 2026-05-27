import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class YourAccountsViewControllerSnapshotTests: SnapshotTestCase {

    func test_loadInNavigationController_success_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeUnlinked)

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
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
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeUnlinked)

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
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
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .failure(.apiUnavailable)
        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
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
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .failure(.apiUnavailable)

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
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
}


