import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct TravelAlertsEditDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = TravelAlertsEditDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/travelalerts/edit")
    }

    @Test
    func action_showEditTravelAlertCountries() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = TravelAlertsEditDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)
        let parentCoordinator = await mockCoordinatorBuilder._mockHomeCoordinator
        #expect(parentCoordinator._didShowEditTravelAlertCountries == false)
        subject.action(parent: parentCoordinator, params: [:])
        #expect(parentCoordinator._didShowEditTravelAlertCountries == true)
    }
}
