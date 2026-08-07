import Foundation
import Testing

@testable import govuk_ios

struct DVLAAuthenticationViewModelTests {

    @Test
    func refreshToken_success_callsFetchIdentityVerification() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .success(.arrange)
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(
                verificationHash: "test-token",
                sessionHash: "test-session",
            )
        )

        let sut = DVLAAuthenticationViewModel(
            authenticationService: mockAuthenticationService,
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: { }
        )
        await sut.refreshToken()
        #expect(mockAuthenticationService._fetchIdentityVerificationCalled == true)
    }

    @Test
    func refreshToken_failure_callsErrorAction() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .failure(.genericError)
        var errorActionWasCalled = false

        let sut = DVLAAuthenticationViewModel(
            authenticationService: mockAuthenticationService,
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: {
                errorActionWasCalled = true
            }
        )
        await sut.refreshToken()
        #expect(errorActionWasCalled == true)
    }

    @Test
    func fetchIdentityVerification_success_callsCompletionAction() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .success(.arrange)
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(
                verificationHash: "test-token",
                sessionHash: "test-session",
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
        await sut.refreshToken()
        #expect(completionActionWasCalled == true)
        #expect(completionActionUrl?.absoluteString == "https://dvla.gov.uk/auth?verification=test-token&session=test-session")
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
        await sut.refreshToken()
        #expect(errorActionWasCalled == true)
    }
}

