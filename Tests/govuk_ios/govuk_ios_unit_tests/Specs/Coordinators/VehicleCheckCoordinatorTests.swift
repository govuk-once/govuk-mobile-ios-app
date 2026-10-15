import Foundation
import UIKit
import Testing
import GovKit
@testable import govuk_ios

@Suite
@MainActor
struct VehicleCheckCoordinatorTests {
    @Test
    func presentationControllerDidDismiss_tracksHandleCloseEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockModalSheet = UIPresentationController(
            presentedViewController: UIViewController(),
            presenting: UIViewController()
        )
        let sut = VehicleCheckCoordinator(
            navigationController: UINavigationController(),
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            urlOpener: MockURLOpener()
        )
        sut.presentationControllerDidDismiss(mockModalSheet)
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
    }
}
