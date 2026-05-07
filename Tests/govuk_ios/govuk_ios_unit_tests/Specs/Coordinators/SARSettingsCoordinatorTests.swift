import Foundation
import UIKit
import Testing
import GovKit
@testable import govuk_ios

@Suite
@MainActor
struct SARSettingsCoordinatorTests {
    @Test
    func start_setsSARViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedSARExplainer = UIViewController()
        mockViewControllerBuilder._stubbedSARExplainer = stubbedSARExplainer
        let root = UINavigationController()
        let sut = SARSettingsCoordinator(
            navigationController: root,
            analyticsService: MockAnalyticsService(),
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService()
        )

        sut.start(url: nil)
        #expect(root.topViewController == stubbedSARExplainer)
    }

    @Test
    func sarAction_pushesResultView() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedSARResults = UIViewController()
        mockViewControllerBuilder._stubbedSARResults = stubbedSARResults
        let root = UINavigationController()
        let sut = SARSettingsCoordinator(
            navigationController: root,
            analyticsService: MockAnalyticsService(),
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService()
        )

        sut.start(url: nil)
        mockViewControllerBuilder._receivedSARAction?()
        #expect(root.viewControllers.count == 2)
        #expect(root.topViewController == stubbedSARResults)
    }
}
