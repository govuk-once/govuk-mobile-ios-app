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
            urlOpener: MockURLOpener(),
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: .arrange
        )

        sut.start(url: nil)
        #expect(root.topViewController == stubbedVehicleDetailController)
    }
}

