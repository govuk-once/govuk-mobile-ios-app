import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct RecentActivityDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = RecentActivityDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/recent-activity")
    }
}
