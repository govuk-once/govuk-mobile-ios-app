import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ServiceAccountCoordinatorTests {
    @Test
    func start_setsAccountLinkingViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountLinkingController = expectedViewController
        let navigationController = UINavigationController()
        var hasCompleted = false
        let sut = ServiceAccountCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService(),
            accountType: .dvla,
            completion: {
                hasCompleted = true
            }
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
        mockViewControllerBuilder._receivedServiceAccountLinkingCompleteAction?()
        #expect(hasCompleted)
    }

    @Test
    func start_accountAlreadyLinked_setsAccountUnlinkingViewController() {
        let mockUserService = MockUserService()
        mockUserService._stubbedIsDvlaAccountLinked = true
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountUnlinkingController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ServiceAccountCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            userService: mockUserService,
            accountType: .dvla,
            completion: {}
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }


}
