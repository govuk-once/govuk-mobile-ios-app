import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class ServiceAccountLinkingViewControllerSnapshotTests: SnapshotTestCase {
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

    func test_loadInNavigationController_error_light_rendersCorrectly() {

        let mockUserService = MockUserService()
        mockUserService._stubbedLinkAccountResult = .failure(UserStateError.apiUnavailable)
        let viewModel = ServiceAccountLinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        let view = ServiceAccountLinkingView(
            viewModel: viewModel
        )
        viewModel.linkAccount()

        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_error_dark_rendersCorrectly() {

        let mockUserService = MockUserService()
        mockUserService._stubbedLinkAccountResult = .failure(UserStateError.apiUnavailable)
        let viewModel = ServiceAccountLinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        let view = ServiceAccountLinkingView(
            viewModel: viewModel
        )
        viewModel.linkAccount()

        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let viewModel = ServiceAccountLinkingViewModel(
            userService: MockUserService(),
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        let view = ServiceAccountLinkingView(
            viewModel: viewModel
        )
        viewModel.linkAccount()
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}
