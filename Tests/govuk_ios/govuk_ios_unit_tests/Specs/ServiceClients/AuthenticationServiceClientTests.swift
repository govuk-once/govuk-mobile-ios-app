import Foundation
import UIKit
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct AuthenticationServiceClientTests {
    @Test @MainActor
    func performAuthenticationFlow_success_returnsSuccess() async {
        let appAuthSessionWrapper = MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedAppCheckToken = .init(
            token: "test123",
            expirationDate: .init(timeIntervalSinceNow: 1000)
        )
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )

        await confirmation() { confirmation in
            let result = await sut.performAuthenticationFlow(window: UIApplication.shared.window!)
            if case .success(let tokenResponse) = result {
                let authSessionResponse = appAuthSessionWrapper._mockAuthenticationSession._tokenResponse
                #expect(tokenResponse.accessToken == authSessionResponse.accessToken)
                #expect(tokenResponse.refreshToken == authSessionResponse.refreshToken)
                #expect(tokenResponse.idToken == authSessionResponse.idToken)
                confirmation()
            }
        }
    }

    @Test @MainActor
    func performAuthenticationFlow_loginFlowError_returnsFailure() async {
        let appAuthSessionWrapper = MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        appAuthSessionWrapper._mockAuthenticationSession._shouldReturnError = true
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedAppCheckToken = .init(
            token: "test123",
            expirationDate: .init(timeIntervalSinceNow: 1000)
        )
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )

        await confirmation() { confirmation in
            let result = await sut.performAuthenticationFlow(window: UIApplication.shared.window!)
            if case .failure(.loginFlow(let error)) = result {
                #expect(error.reason == .userCancelled)
                confirmation()
            }
        }
    }

    @Test @MainActor
    func performAuthenticationFlow_attestationError_returnsFailure() async {
        let appAuthSessionWrapper = MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        appAuthSessionWrapper._mockAuthenticationSession._shouldReturnError = true
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedTokenFetchError = AppAttestError.tokenGeneration
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )

        await confirmation() { confirmation in
            let result = await sut.performAuthenticationFlow(window: UIApplication.shared.window!)
            if case .failure(.attestation(.tokenGeneration)) = result {
                confirmation()
            }
        }
    }

    @Test @MainActor
    func performAuthenticationFlow_unknownError_returnsFailure() async {
        let appAuthSessionWrapper = MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        appAuthSessionWrapper._mockAuthenticationSession._shouldReturnError = true
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedTokenFetchError = TestError.anyError
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )

        await confirmation() { confirmation in
            let result = await sut.performAuthenticationFlow(window: UIApplication.shared.window!)
            if case .failure(.unknown(TestError.anyError)) = result {
                confirmation()
            }
        }
    }

    @Test
    func performTokenRefresh_success_returnsSuccess() async {
        let appAuthSessionWrapper = await MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedAppCheckToken = .init(
            token: "test123",
            expirationDate: .init(timeIntervalSinceNow: 1000)
        )
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )
        let accessToken = UUID().uuidString
        let idToken = UUID().uuidString
        mockOidAuthService._stubbedAccessToken = accessToken
        mockOidAuthService._stubbedIdToken = idToken

        await confirmation() { confirmation in
            let result = await sut.performTokenRefresh(refreshToken: UUID().uuidString)
            if case .success(let tokenResponse) = result {
                #expect(tokenResponse.accessToken == accessToken)
                #expect(tokenResponse.idToken == idToken)
                confirmation()
            }
        }
    }

    @Test
    func performTokenRefresh_missingAccessToken_returnsFailure() async {
        let appAuthSessionWrapper = await MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedAppCheckToken = .init(
            token: "test123",
            expirationDate: .init(timeIntervalSinceNow: 1000)
        )
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )
        mockOidAuthService._stubbedAccessToken = nil

        await confirmation() { confirmation in
            let result = await sut.performTokenRefresh(refreshToken: UUID().uuidString)
            if case .failure(let error) = result {
                #expect(error == .missingAccessTokenError)
                confirmation()
            }
        }
    }

    @Test
    func performTokenRefresh_oidAuthServiceError_returnsFailure() async {
        let appAuthSessionWrapper = await MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockAttestService = MockAppAttestService()
        mockAttestService._stubbedAppCheckToken = .init(
            token: "test123",
            expirationDate: .init(timeIntervalSinceNow: 1000)
        )
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: MockAPIServiceClient(),
            appAttestService: mockAttestService,
        )
        mockOidAuthService._shouldReturnError = true

        await confirmation() { confirmation in
            let result = await sut.performTokenRefresh(refreshToken: UUID().uuidString)
            if case .failure(let error) = result {
                #expect(error == .tokenResponseError)
                confirmation()
            }
        }
    }

    @Test
    func revokeTokenSuccess_callsCompletion() async {
        let appAuthSessionWrapper = await MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .success(Data())
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        let result = await withCheckedContinuation { continuation in
            sut.revokeToken("token") {
                continuation.resume(returning: true)
            }
        }

        #expect(result)
    }

    @Test
    func revokeTokenFailure_doesNot_callsCompletion() async {
        let appAuthSessionWrapper = await MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .failure(TestError.fakeNetwork)
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        var didCallCompletion: Bool = false
        let _ = await withCheckedContinuation { continuation in
            sut.revokeToken("token") {
                didCallCompletion = true
            }
            continuation.resume()
        }

        #expect(!didCallCompletion)
    }

    @Test
    func revokeToken_nilToken_doesNot_callsCompletion() async {
        let appAuthSessionWrapper = await MockAuthenticationSessionWrapper()
        let mockOidAuthService = MockOIDAuthService()
        let mockAppEnvironmentService = MockAppEnvironmentService()
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .success(Data())
        let sut = AuthenticationServiceClient(
            appEnvironmentService: mockAppEnvironmentService,
            appAuthSession: appAuthSessionWrapper,
            oidAuthService: mockOidAuthService,
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        var didCallCompletion: Bool = false
        sut.revokeToken(nil) {
            didCallCompletion = true
        }

        #expect(!didCallCompletion)
    }

    // MARK: - fetchIdentityVerification

    @Test
    func fetchIdentityVerification_sendsExpectedRequest() async {
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .success(Data())
        let sut = AuthenticationServiceClient(
            appEnvironmentService: MockAppEnvironmentService(),
            appAuthSession: await MockAuthenticationSessionWrapper(),
            oidAuthService: MockOIDAuthService(),
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        _ = await sut.fetchIdentityVerification(accesstoken: "test-token")

        #expect(mockTokenApiClient._receivedSendRequest?.urlPath == "/linking/verification")
        #expect(mockTokenApiClient._receivedSendRequest?.method == .post)
        #expect(mockTokenApiClient._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func fetchIdentityVerification_success_returnsExpectedResult() async throws {
        let hash = "some-identity-token"
        let encoded = try #require(try? JSONEncoder().encode(["verificationHash": hash]))
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .success(encoded)
        let sut = AuthenticationServiceClient(
            appEnvironmentService: MockAppEnvironmentService(),
            appAuthSession: await MockAuthenticationSessionWrapper(),
            oidAuthService: MockOIDAuthService(),
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        let result = await sut.fetchIdentityVerification(accesstoken: "test-token")
        let value = try #require(try? result.get())
        #expect(value.verificationHash == hash)
    }

    @Test
    func fetchIdentityVerification_apiUnavailable_returnsExpectedError() async {
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .failure(VerificationHashError.apiUnavailable)
        let sut = AuthenticationServiceClient(
            appEnvironmentService: MockAppEnvironmentService(),
            appAuthSession: await MockAuthenticationSessionWrapper(),
            oidAuthService: MockOIDAuthService(),
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        let result = await sut.fetchIdentityVerification(accesstoken: "test-token")
        #expect(result.getError() == .apiUnavailable)
    }

    @Test
    func fetchIdentityVerification_networkUnavailable_returnsExpectedError() async {
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .failure(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        )
        let sut = AuthenticationServiceClient(
            appEnvironmentService: MockAppEnvironmentService(),
            appAuthSession: await MockAuthenticationSessionWrapper(),
            oidAuthService: MockOIDAuthService(),
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )

        let result = await sut.fetchIdentityVerification(accesstoken: "test-token")
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func fetchIdentityVerification_malformedResponse_returnsDecodingError() async {
        let mockTokenApiClient = MockAPIServiceClient()
        mockTokenApiClient._stubbedSendResponse = .success(Data("not valid json".utf8))
        let sut = AuthenticationServiceClient(
            appEnvironmentService: MockAppEnvironmentService(),
            appAuthSession: await MockAuthenticationSessionWrapper(),
            oidAuthService: MockOIDAuthService(),
            tokenServiceClient: mockTokenApiClient,
            appAttestService: MockAppAttestService()
        )
        let result = await sut.fetchIdentityVerification(accesstoken: "test-token")
        #expect(result.getError() == .decodingError)
    }

}
