import Foundation
import UIKit
import Testing
import GovKit
@testable import govuk_ios

@Suite
@MainActor
struct VehicleDetailCoordinatorTests {
    @Test
    func start_setsSARViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedVehicleDetailController = UIViewController()
        mockViewControllerBuilder._stubbedVehicleDetailController = stubbedVehicleDetailController
        let root = UINavigationController()
        let sut = VehicleDetailCoordinator(
            navigationController: root,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            vehicleId: 1
        )

        sut.start(url: nil)
        #expect(root.topViewController == stubbedVehicleDetailController)
    }
}

