import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
struct DVLAAuthenticationServiceTests {

    static let linkIdToken = """
        eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjM2MDAsImxpbmtpbmdfaWQiOiJ0ZXN0LWxpbmstaWQifQ.SFLKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
        """

    @Test
    @MainActor
    func authenticate_success_returnsLinkId() async throws {

        let mockAuthSession = MockDVLAAuthSession()
        mockAuthSession._stubbedCallbackUrl = URL(string: "govuk://returnedToken?token=\(Self.linkIdToken)")!

        let mockSessionBuilder = MockDVLAAuthSessionBuilder()
        mockSessionBuilder._stubbedSession = mockAuthSession
        let sut = DVLAAuthenticationService(sessionBuilder: mockSessionBuilder)

        let window = UIWindow()
        let result = await sut.authenticate(window: window)
        let linkId = try result.get()
        #expect(linkId == "test-link-id")
    }

    @Test
    @MainActor
    func authenticate_invalidToken_returnsExpectedError() async throws {
        let mockAuthSession = MockDVLAAuthSession()
        mockAuthSession._stubbedCallbackUrl = URL(string: "govuk://returnedToken?token=")!

        let mockSessionBuilder = MockDVLAAuthSessionBuilder()
        mockSessionBuilder._stubbedSession = mockAuthSession
        let sut = DVLAAuthenticationService(sessionBuilder: mockSessionBuilder)

        let window = UIWindow()
        let result = await sut.authenticate(window: window)
        let error = result.getError()
        #expect(error == DVLAAuthError.linkIdNotFound)
    }

    @Test
    @MainActor
    func authenticate_missingToken_returnsExpectedError() async throws {
        let mockAuthSession = MockDVLAAuthSession()
        mockAuthSession._stubbedCallbackUrl = URL(string: "govuk://")!

        let mockSessionBuilder = MockDVLAAuthSessionBuilder()
        mockSessionBuilder._stubbedSession = mockAuthSession
        let sut = DVLAAuthenticationService(sessionBuilder: mockSessionBuilder)

        let window = UIWindow()
        let result = await sut.authenticate(window: window)
        let error = result.getError()
        #expect(error == DVLAAuthError.tokenNotFound)
    }

    @Test
    @MainActor
    func authenticate_userCancelled_returnsExpectedError() async throws {

        let mockAuthSession = MockDVLAAuthSession()
        mockAuthSession._stubbedError = DVLAAuthError.userCancelled

        let mockSessionBuilder = MockDVLAAuthSessionBuilder()
        mockSessionBuilder._stubbedSession = mockAuthSession
        let sut = DVLAAuthenticationService(sessionBuilder: mockSessionBuilder)

        let window = UIWindow()
        let result = await sut.authenticate(window: window)
        let error = result.getError()
        #expect(error == DVLAAuthError.userCancelled)
    }

}
