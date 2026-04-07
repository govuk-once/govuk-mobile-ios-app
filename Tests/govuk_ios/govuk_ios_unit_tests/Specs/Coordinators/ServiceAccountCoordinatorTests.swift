import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ServiceAccountCoordinatorTests {
    @Test
    func start_accountNotLinked_setsAccountConsentViewController() {
        let mockUserService = MockUserService()
        mockUserService._stubbedIsDvlaAccountLinked = false
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountConsentController = expectedViewController
        let mockNavigationController = MockNavigationController()
        let sut = ServiceAccountCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            completion: { _ in }
        )

        sut.start()
        let firstViewController = mockNavigationController._setViewControllers?.first
        #expect(firstViewController == expectedViewController)
    }

    @Test
    func accountConsentCompletion_startsAuthenticationCoordinator() {
        let mockUserService = MockUserService()
        mockUserService._stubbedIsDvlaAccountLinked = false
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let authenticationCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedDvlaAuthenticationCoordinator = authenticationCoordinator
        let sut = ServiceAccountCoordinator(
            navigationController: MockNavigationController(),
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            completion: { _ in }
        )

        sut.start()
        mockViewControllerBuilder._receivedServiceAccountConsentCompletionAction?()

        #expect(authenticationCoordinator._startCalled == true)
    }

    @Test
    func authenticationCompletion_setsAccountLinkingViewController() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let authenticationCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedDvlaAuthenticationCoordinator = authenticationCoordinator
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountLinkingController = expectedViewController
        let mockNavigationController = MockNavigationController()
        var hasCompleted = false
        let sut = ServiceAccountCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            accountType: .dvla,
            completion: { _ in
                hasCompleted = true
            }
        )

        sut.start()
        mockViewControllerBuilder._receivedServiceAccountConsentCompletionAction?()
        mockCoordinatorBuilder._receivedDvlaAuthenticationCompletion?("link-id")

        let firstViewController = mockNavigationController._setViewControllers?.first
        #expect(firstViewController == expectedViewController)
        mockViewControllerBuilder._receivedServiceAccountLinkingCompleteAction?()
        #expect(hasCompleted)
    }

    @Test
    func start_accountAlreadyLinked_setsAccountUnlinkingViewController() {
        let mockUserService = MockUserService()
        mockUserService._stubbedIsDvlaAccountLinked = true
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountUnlinkingController = expectedViewController
        let mockNavigationController = MockNavigationController()
        let sut = ServiceAccountCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            completion: { _ in }
        )

        sut.start()
        let firstViewController = mockNavigationController._setViewControllers?.first
        #expect(firstViewController == expectedViewController)
    }


}
