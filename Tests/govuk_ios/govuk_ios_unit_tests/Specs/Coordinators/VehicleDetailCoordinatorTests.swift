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
            urlOpener: mockURLOpener,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: .arrange
        )
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleDetailOpenURLAction?(mockURL)

        #expect(mockURLOpener._receivedOpenIfPossibleUrl?.absoluteString == "https://gov.uk")
    }
}

