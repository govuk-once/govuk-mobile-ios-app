import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DVLAServiceDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = DVLAServiceDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/callback/dvla/auth")
    }

    @Test
    func action_redirectsWithCorrectToken() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock

        let subject = DVLAServiceDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)
        let mockBaseCoordinator = MockBaseCoordinator()
        let expectedToken = "test123"
        subject.action(parent: mockBaseCoordinator, params: ["token": expectedToken])

        #expect(mockCoordinatorBuilder._receivedServiceAccountRedirectToken == expectedToken)
    }
}
