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
    func setNotificationsConsent_sendsExpectedRequest() {
        sut.setNotificationsConsent(accepted: true) { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/v1/user")
        #expect(mockAPI._receivedSendRequest?.method == .patch)
        #expect(mockAPI._receivedSendRequest?.bodyParameters as? [String: AnyHashable] == ["notificationsConsented": true])
    }

    @Test
    func setNotificationsConsent_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(UserServiceClientTests.notificationConsentResponseData)
        let result = await withCheckedContinuation { continuation in
            sut.setNotificationsConsent(accepted: true) { result in
                continuation.resume(returning: result)
            }
        }
        let notificationsConsentResponse = try? result.get()
        #expect(notificationsConsentResponse?.preferences.notificationsConsented == true)
    }

    @Test
    func setNotificationsConsent_failure_returnsApiUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(UserStateError.apiUnavailable)
        let result = await withCheckedContinuation { continuation in
            sut.setNotificationsConsent(accepted: true) { result in
                continuation.resume(returning: result)
            }
        }
        let userStateResponse = try? result.get()
        #expect(userStateResponse == nil)
        #expect(result.getError() == .apiUnavailable)
    }
}

private extension UserServiceClientTests {
    static let userStateData =
    """
    {
        "notificationId": "test_user_id",
        "preferences": {
            "notificationsConsented": true,
            "updatedAt": "2026-02-03T09:33:13.459Z"
        }
    }
    """.data(using: .utf8)!

    static let notificationConsentResponseData =
    """
    {
        "preferences": {
            "notificationsConsented": true,
            "updatedAt": "2026-02-03T09:33:13.459Z"
        }
    }
    """.data(using: .utf8)!
}
