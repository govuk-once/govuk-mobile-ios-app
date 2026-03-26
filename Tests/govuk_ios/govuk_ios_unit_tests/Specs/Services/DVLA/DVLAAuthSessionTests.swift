import Foundation
import AuthenticationServices
import UIKit
import Testing

@testable import govuk_ios

@Suite(.serialized)
struct DVLAAuthSessionTests {
    init() {
        MockASWebAuthenticationSession.lastInstance = nil
        MockASWebAuthenticationSession._stubbedCallbackUrl = nil
        MockASWebAuthenticationSession._stubbedError = nil
    }

    @Test
    @MainActor
    func start_success_returnsExpectedResult() async throws {
        let window = UIWindow()
        let config = DVLAAuthSessionConfig(
            authenticationUrl: URL(string: "www.dvla.gov.uk")!,
            callbackUrlScheme: "govuk"
        )
        MockASWebAuthenticationSession._stubbedCallbackUrl = URL(string: "govuk://returnedToken?token=test")!
        let sut = DVLAAuthSession(window: window, sessionType: MockASWebAuthenticationSession.self)
        let result = try await sut.start(config: config)
        let receivedAuthenticationSession = MockASWebAuthenticationSession.lastInstance
        #expect(receivedAuthenticationSession?._receivedUrl == URL(string: "www.dvla.gov.uk")!)
        #expect(receivedAuthenticationSession?._receivedCallbackURLScheme == "govuk")
        #expect(result == URL(string: "govuk://returnedToken?token=test"))
    }

    @Test
    @MainActor
    func start_canceledLogin_returnsExpectedError() async throws {
        let window = UIWindow()
        let config = DVLAAuthSessionConfig(
            authenticationUrl: URL(string: "www.dvla.gov.uk")!,
            callbackUrlScheme: "govuk"
        )
        MockASWebAuthenticationSession._stubbedError = ASWebAuthenticationSessionError(.canceledLogin)
        let sut = DVLAAuthSession(window: window, sessionType: MockASWebAuthenticationSession.self)
        await #expect(throws: DVLAAuthError.userCancelled) {
            try await sut.start(config: config)
        }
    }

    @Test
    @MainActor
    func start_missingCallbackUrl_returnsExpectedError() async throws {
        let window = UIWindow()
        let config = DVLAAuthSessionConfig(
            authenticationUrl: URL(string: "www.dvla.gov.uk")!,
            callbackUrlScheme: "govuk"
        )
        MockASWebAuthenticationSession._stubbedCallbackUrl = nil
        let sut = DVLAAuthSession(window: window, sessionType: MockASWebAuthenticationSession.self)
        await #expect(throws: DVLAAuthError.invalidCallbackUrl) {
            try await sut.start(config: config)
        }
    }
}
