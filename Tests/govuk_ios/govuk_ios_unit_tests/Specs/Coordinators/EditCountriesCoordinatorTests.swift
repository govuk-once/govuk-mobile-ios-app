//


import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct EditCountriesCoordinatorTests {

    @Test
    func start_setsEditCountriesViewController() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedEditCountriesViewController = expectedViewController

        let sut = EditCountriesCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            completion: { }
        )

        sut.start(url: nil)

        #expect(mockNavigationController.viewControllers.first == expectedViewController)
    }

    @Test
    func start_withURL_setsEditCountriesViewController() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let testURL = URL(string: "https://example.com")!
        mockViewControllerBuilder._stubbedEditCountriesViewController = expectedViewController

        let sut = EditCountriesCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            completion: { }
        )

        sut.start(url: testURL)

        #expect(mockNavigationController.viewControllers.first == expectedViewController)
    }
}
