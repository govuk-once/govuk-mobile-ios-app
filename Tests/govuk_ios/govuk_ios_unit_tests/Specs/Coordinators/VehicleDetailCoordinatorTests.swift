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
            urlOpener: MockURLOpener(),
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
            urlOpener: mockURLOpener,
            vehicleId: 1
        )
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleDetailOpenURLAction?(mockURL)

        #expect(mockURLOpener._receivedOpenIfPossibleUrl?.absoluteString == "https://gov.uk")
    }
}

