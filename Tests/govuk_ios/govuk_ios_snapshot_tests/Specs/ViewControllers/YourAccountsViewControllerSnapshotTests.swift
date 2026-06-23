import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class YourAccountsViewControllerSnapshotTests: SnapshotTestCase {

    func test_loadInNavigationController_success_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            unlinkErrorAction: {}
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
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(), unlinkErrorAction: {}
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
        mockUserService._stubbedFetchLinkedAccountsResult = .failure(.apiUnavailable)
        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            unlinkErrorAction: {}
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
        mockUserService._stubbedFetchLinkedAccountsResult = .failure(.apiUnavailable)

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(), unlinkErrorAction: {}
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

    func test_loadInNavigationController_empty_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([])
        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(), unlinkErrorAction: {}
        )
        viewModel.state = .empty
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

    func test_loadInNavigationController_empty_dark_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([])

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(), unlinkErrorAction: {}
        )
        viewModel.state = .empty
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

    func test_loadInNavigationController_success_editMode_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            unlinkErrorAction: {}
        )
        viewModel.state = .success
        let view = YourAccountsView(viewModel: viewModel, isEditMode: true)

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

    func test_loadInNavigationController_success_editMode_dark_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])

        let viewModel = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            unlinkErrorAction: {}
        )
        viewModel.state = .success
        let view = YourAccountsView(viewModel: viewModel, isEditMode: true)

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


