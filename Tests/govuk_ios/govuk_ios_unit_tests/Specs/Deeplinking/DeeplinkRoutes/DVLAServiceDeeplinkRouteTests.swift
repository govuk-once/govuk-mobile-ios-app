import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DVLAServiceDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockAnalyticsService = MockAnalyticsService()
        let subject = DVLAServiceDeeplinkRoute(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: mockAnalyticsService
        )

        #expect(subject.pattern == "/callback/dvla/auth")
    }

    @Test
    func action_redirectsWithCorrectToken() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockAnalyticsService = MockAnalyticsService()
        let subject = DVLAServiceDeeplinkRoute(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: mockAnalyticsService
        )
        let mockBaseCoordinator = MockBaseCoordinator()
        let expectedToken = "test123"

        subject.action(parent: mockBaseCoordinator, params: ["token": expectedToken])

        #expect(mockCoordinatorBuilder._receivedServiceAccountRedirectToken == expectedToken)
    }

    @Test
    func action_failure_recordsError() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockAnalyticsService = MockAnalyticsService()
        let subject = DVLAServiceDeeplinkRoute(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: mockAnalyticsService
        )
        let mockBaseCoordinator = MockBaseCoordinator()

        subject.action(parent: mockBaseCoordinator, params: ["failure": "true"])

        let errors = mockAnalyticsService._trackErrorReceivedErrors
        #expect(mockCoordinatorBuilder._receivedServiceAccountRedirectToken == nil)
        #expect(errors.count == 1)
        #expect(errors.first?.localizedDescription == "DVLA account linking failed")
    }

    @Test
    func action_failureWithMessage_recordsError() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockAnalyticsService = MockAnalyticsService()
        let subject = DVLAServiceDeeplinkRoute(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: mockAnalyticsService
        )
        let mockBaseCoordinator = MockBaseCoordinator()
        let expectedErrorMessage = "Some error message"
        subject.action(
            parent: mockBaseCoordinator,
            params: [
                "failure": "true",
                "errorMessage": expectedErrorMessage
            ]
        )

        let errors = mockAnalyticsService._trackErrorReceivedErrors
        #expect(mockCoordinatorBuilder._receivedServiceAccountRedirectToken == nil)
        #expect(errors.count == 1)
        #expect(errors.first?.localizedDescription == expectedErrorMessage)
    }
}
