import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ServiceAccountCoordinatorTests {
    @Test
    func start_setsAccountLinkingViewController() throws {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountLinkingController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ServiceAccountCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService(),
            accountType: .dvla
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }


}
