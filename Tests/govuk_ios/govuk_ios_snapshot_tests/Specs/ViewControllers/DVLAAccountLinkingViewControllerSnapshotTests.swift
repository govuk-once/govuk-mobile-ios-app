import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class DVLAAccountLinkingViewControllerSnapshotTests: SnapshotTestCase {
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

        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedLinkAccountResult = .failure(DVLAError.apiUnavailable)
        let viewModel = DVLAAccountLinkingViewModel(
            dvlaService: mockDvlaService,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        let view = DVLAAccountLinkingView(
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

        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedLinkAccountResult = .failure(DVLAError.apiUnavailable)
        let viewModel = DVLAAccountLinkingViewModel(
            dvlaService: mockDvlaService,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        let view = DVLAAccountLinkingView(
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
        let viewModel = DVLAAccountLinkingViewModel(
            dvlaService: MockDVLAService(),
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        let view = DVLAAccountLinkingView(
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
