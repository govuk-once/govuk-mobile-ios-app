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

    func test_loadInNavigationController_apiUnavailableError_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedLinkAccountResult = .failure(UserStateError.apiUnavailable)
        let viewModel = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            token: "test-link-id",
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

    func test_loadInNavigationController_apiUnavailableError_dark_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedLinkAccountResult = .failure(UserStateError.apiUnavailable)
        let viewModel = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            token: "test-link-id",
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

    func test_loadInNavigationController_networkUnavailableError_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedLinkAccountResult = .failure(.networkUnavailable)
        let viewModel = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            token: "test-link-id",
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

    func test_loadInNavigationController_networkUnavailableError_dark_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedLinkAccountResult = .failure(.networkUnavailable)
        let viewModel = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            token: "test-link-id",
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
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            accountType: .dvla,
            token: "test-link-id",
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
