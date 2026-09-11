import Foundation
import Testing

@testable import govuk_ios

struct DVLAAuthenticationViewModelTests {

    @Test
    func fetchIdentityVerification_success_callsCompletionAction() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .success(.arrange)
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(
                token: "test-token",
            )
        )
        let mockAppEnvironmentService = MockAppEnvironmentService()
        mockAppEnvironmentService.dvlaAuthenticationURL = URL(string: "https://dvla.gov.uk/auth")!

        var completionActionWasCalled = false
        var completionActionUrl: URL? = nil

        let sut = DVLAAuthenticationViewModel(
            authenticationService: mockAuthenticationService,
            appEnvironmentService: mockAppEnvironmentService,
            completionAction: { url in
                completionActionWasCalled = true
                completionActionUrl = url
            },
            errorAction: { }
        )
        await sut.fetchIdentityVerification()
        #expect(completionActionWasCalled == true)
        #expect(completionActionUrl?.absoluteString == "https://dvla.gov.uk/auth?token=test-token")
    }

    @Test
    func fetchIdentityVerification_failure_callsErrorAction() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .success(.arrange)
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .failure(.apiUnavailable)
        var errorActionWasCalled = false

        let sut = DVLAAuthenticationViewModel(
            authenticationService: mockAuthenticationService,
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: {
                errorActionWasCalled = true
            }
        )
        await sut.fetchIdentityVerification()
        #expect(errorActionWasCalled == true)
    }
}
