import Foundation
import UIKit
import Testing
import GovKit
@testable import govuk_ios

@Suite
@MainActor
struct VehicleDetailCoordinatorTests {
    @Test
    func start_setsVehicleDetailViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedVehicleDetailController = UIViewController()
        mockViewControllerBuilder._stubbedVehicleDetailController = stubbedVehicleDetailController
        let root = UINavigationController()
        let sut = VehicleDetailCoordinator(
            navigationController: root,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            configService: MockAppConfigService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            notificationCenter: MockNotificationCenter(),
            vehicleId: 1
        )

        sut.start(url: nil)
        #expect(root.topViewController == stubbedVehicleDetailController)
    }

    @Test
    func openURLAction_opensURL() {
        let mockURL = URL(string: "https://gov.uk")!
        let mockURLOpener = MockURLOpener()
        let stubbedVehicleDetailController = UIViewController()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        mockViewControllerBuilder._stubbedVehicleDetailController = stubbedVehicleDetailController
        let sut = VehicleDetailCoordinator(
            navigationController: UINavigationController(),
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            configService: MockAppConfigService(),
            userService: MockUserService(),
            urlOpener: mockURLOpener,
            notificationCenter: MockNotificationCenter(),
            vehicleId: 1
        )
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleDetailOpenURLAction?(mockURL)

        #expect(mockURLOpener._receivedOpenIfPossibleUrl?.absoluteString == "https://gov.uk")
    }

    @Test
    func linkedAccountsDidChangeNotification_popsViewController() {
        let mockUserService = MockUserService()
        mockUserService._stubbedLinkedAccounts = []
        let mockNotificationCenter = MockNotificationCenter()
        let mockNavigationController = MockNavigationController()

        let sut = VehicleDetailCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: MockViewControllerBuilder(),
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            configService: MockAppConfigService(),
            userService: mockUserService,
            urlOpener: MockURLOpener(),
            notificationCenter: mockNotificationCenter,
            vehicleId: 1
        )
        sut.start(url: nil)

        mockNotificationCenter.post(name: Notification.Name.linkedAccountsDidChange, object: nil)
        #expect(mockNavigationController._popCalled == true)
    }
}

