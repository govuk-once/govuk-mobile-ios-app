import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class ServiceAccountUnlinkingViewControllerSnapshotTests: SnapshotTestCase {
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
        mockUserService._stubbedUnlinkAccountResult = .failure(UserStateError.apiUnavailable)
        let viewModel = ServiceAccountUnlinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            completeAction: {},
            dismissAction: {}
        )
        let view = ServiceAccountUnlinkingView(
            viewModel: viewModel
        )
        viewModel.unlinkAccount()

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
        mockUserService._stubbedUnlinkAccountResult = .failure(UserStateError.apiUnavailable)
        let viewModel = ServiceAccountUnlinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            completeAction: {},
            dismissAction: {}
        )
        let view = ServiceAccountUnlinkingView(
            viewModel: viewModel
        )
        viewModel.unlinkAccount()

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
        let viewModel = ServiceAccountUnlinkingViewModel(
            userService: MockUserService(),
            accountType: .dvla,
            completeAction: {},
            dismissAction: {}
        )
        let view = ServiceAccountUnlinkingView(
            viewModel: viewModel
        )
        viewModel.unlinkAccount()
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}
