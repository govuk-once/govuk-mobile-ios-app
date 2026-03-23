import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct EditTopicsDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = EditTopicsDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/edit-topics")
    }
}
