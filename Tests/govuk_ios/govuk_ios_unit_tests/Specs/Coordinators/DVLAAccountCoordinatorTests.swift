import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DVLAAccountCoordinatorTests {
    @Test
    func start_setsAccountLinkingViewController() throws {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedDvlaAccountLinkingController = expectedViewController
        let navigationController = UINavigationController()
        let sut = DVLAAccountCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            dvlaService: MockDVLAService()
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }


}
