import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ServiceAccountUnlinkCoordinatorTests {

    @Test
    func start_setsAccountUnlinkingViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountUnlinkingController = expectedViewController
        let mockNavigationController = MockNavigationController()
        let sut = ServiceAccountUnlinkCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService(),
            accountType: .dvla,
            completion: { }
        )

        sut.start()
        let firstViewController = mockNavigationController._setViewControllers?.first
        #expect(firstViewController == expectedViewController)
    }
}
