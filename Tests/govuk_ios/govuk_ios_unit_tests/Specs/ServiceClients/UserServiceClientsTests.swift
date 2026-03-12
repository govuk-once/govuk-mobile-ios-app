import Foundation
import Testing
@testable import govuk_ios

@Suite
struct UserServiceClientTests {

    var mockAPI: MockAPIServiceClient!
    var mockAuthenticationService: MockAuthenticationService!
    var sut: UserServiceClient!

    init() {
        mockAPI = MockAPIServiceClient()
        mockAuthenticationService = MockAuthenticationService()
        sut = UserServiceClient(
            apiServiceClient: mockAPI,
            authenticationService: mockAuthenticationService
        )
    }

    @Test
    func fetchUserState_sendsExpectedRequest() {
        sut.fetchUserState { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/v1/user")
        #expect(mockAPI._receivedSendRequest?.method == .get)
    }

    @Test
    func fetchUserState_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(UserServiceClientTests.userStateData)
        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState { result in
                continuation.resume(returning: result)
            }
        }
        let userState = try? result.get()
        #expect(userState?.notificationId == "test_user_id")
        #expect(userState?.preferences.notifications.consentStatus == .unknown)
    }

    @Test
    func fetchUserState_failure_returnsApiUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(UserStateError.apiUnavailable)
        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState { result in
                continuation.resume(returning: result)
            }
        }
        let userState = try? result.get()
        #expect(userState == nil)
        #expect(result.getError() == .apiUnavailable)
    }

    @Test
    func fetchUserState_invalidJson_returnsDecodingError() async {
        mockAPI._stubbedSendResponse = .success("bad json".data(using: .utf8)!)
        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState { result in
                continuation.resume(returning: result)
            }
        }
        let userStateResponse = try? result.get()
        #expect(userStateResponse == nil)
        #expect(result.getError() == .decodingError)
    }

    @Test
    func fetchUserState_networkUnavailable_returnsNetworkUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState { result in
                continuation.resume(returning: result)
            }
        }
        let userStateResponse = try? result.get()
        #expect(userStateResponse == nil)
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func setNotificationsConsent_sendsExpectedRequest() throws {
        sut.setNotificationsConsent(.accepted) { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/v1/user")
        #expect(mockAPI._receivedSendRequest?.method == .patch)
        let body = try #require(mockAPI._receivedSendRequest?.body as? NotificationsPreferenceUpdate)
        #expect(body.preferences.notifications.consentStatus == .accepted)
    }

    @Test
    func setNotificationsConsent_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(UserServiceClientTests.notificationConsentResponseData)
        let result = await withCheckedContinuation { continuation in
            sut.setNotificationsConsent(.accepted) { result in
                continuation.resume(returning: result)
            }
        }
        let notificationsConsentResponse = try? result.get()
        #expect(notificationsConsentResponse?.preferences.notifications.consentStatus == .accepted)
    }

    @Test
    func setNotificationsConsent_failure_returnsApiUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(UserStateError.apiUnavailable)
        let result = await withCheckedContinuation { continuation in
            sut.setNotificationsConsent(.accepted) { result in
                continuation.resume(returning: result)
            }
        }
        let userStateResponse = try? result.get()
        #expect(userStateResponse == nil)
        #expect(result.getError() == .apiUnavailable)
    }

    @Test
    func linkAccount_sendsExpectedRequest() {
        sut.linkAccount(serviceName: "dvla",
                        linkId: "test-link-id") { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/v1/identity/dvla/test-link-id")
        #expect(mockAPI._receivedSendRequest?.method == .post)
    }

    @Test
    func linkAccount_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(Data())
        let isSuccess = await withCheckedContinuation { continuation in
            sut.linkAccount(serviceName: "dvla",
                            linkId: "test-link-id") { result in
                switch result {
                case .success:
                    continuation.resume(returning: true)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
        #expect(isSuccess == true)
    }

    @Test
    func linkAccount_authenticationError_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(UserStateError.authenticationError)

        let result = await withCheckedContinuation { continuation in
            sut.linkAccount(serviceName: "dvla",
                            linkId: "test-link-id") {
                continuation.resume(returning: $0)
            }
        }

        let error = result.getError()
        #expect(error == .authenticationError)
    }

    @Test
    func linkAccount_networkUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )

        let result = await withCheckedContinuation { continuation in
            sut.linkAccount(serviceName: "dvla",
                            linkId: "test-link-id") { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }
}

private extension UserServiceClientTests {
    static let userStateData =
    """
    {
        "notificationId": "test_user_id",
        "preferences": {
            "notifications": {
                "consentStatus": "unknown"
            }
        }
    }
    """.data(using: .utf8)!

    static let notificationConsentResponseData =
    """
    {
        "preferences": {
            "notifications": {
                "consentStatus": "accepted"
            }
        }
    }
    """.data(using: .utf8)!

}
