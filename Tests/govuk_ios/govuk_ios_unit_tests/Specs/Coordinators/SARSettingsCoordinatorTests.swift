import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct SARSettingsCoordinatorTests {
    @Test
    func start_setsSARViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedSARSettings = UIViewController()
        mockViewControllerBuilder._stubbedSARSettings = stubbedSARSettings
        let root = UINavigationController()
        let coordinator = SARSettingsCoordinator(
            navigationController: root,
            analyticsService: MockAnalyticsService(),
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService()
        )

        coordinator.start(url: nil)
        #expect(root.topViewController == stubbedSARSettings)
    }

    @Test
    func sarAction_invokesUserInfoRequest() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedSARSettings = UIViewController()
        mockViewControllerBuilder._stubbedSARSettings = stubbedSARSettings
        let root = UINavigationController()
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchUserStateResult = .success(
            UserState(
                userId: "ID",
                notifications: UserNotificationsPreferences(
                    consentStatus: .accepted,
                    pushId: "pushId"
                )
            )
        )

        let coordinator = SARSettingsCoordinator(
            navigationController: root,
            analyticsService: MockAnalyticsService(),
            viewControllerBuilder: mockViewControllerBuilder,
            userService: mockUserService
        )

        coordinator.start(url: nil)
        mockViewControllerBuilder._receivedSARAction?()
        #expect(coordinator.userState?.userId == "ID")
    }
}
