import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct NotificationCentreDetailDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = NotificationCentreDetailDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/notificationcentre/detail")
    }
}
