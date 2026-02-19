import Foundation
import Testing

@testable import govuk_ios

@Suite
final class UserServiceTests {
    var mockUserServiceClient: MockUserServiceClient!
    var sut: UserService!

    init() {
        mockUserServiceClient = MockUserServiceClient()
        sut = UserService(userServiceClient: mockUserServiceClient)
    }

    @Test
    func fetchUserState_returnsExpectedValue() async throws {
        mockUserServiceClient._stubbedFetchUserStateResult = .success(UserState.arrange)

        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState(completion: {
                continuation.resume(returning: $0)
            })
        }

        let userStateResponse = try #require(try? result.get())
        #expect(userStateResponse.notificationId == "test_id")

    }

    @Test
    func fetchUserState_returnsExpectedError() async throws {
        mockUserServiceClient._stubbedFetchUserStateResult = .failure(UserStateError.apiUnavailable)

        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState(completion: {
                continuation.resume(returning: $0)
            })
        }

        let userStateError = try #require(result.getError())
        #expect(userStateError == UserStateError.apiUnavailable)
    }

    @Test
    func fetchUserState_setsNotificationsConsent() async throws {
        mockUserServiceClient?._stubbedFetchUserStateResult = .success(UserState.arrange(notificationsConsentStatus: .accepted))
        await withCheckedContinuation { continuation in
            sut.fetchUserState(completion: { _ in
                continuation.resume()
            })
        }

        #expect(sut.notificationsConsentStatus == .accepted)
    }

    @Test
    func setNotificationConsent_callsClient() {
        sut.setNotificationsConsent(.accepted)
        #expect(mockUserServiceClient._receivedNotificationConsent == .accepted)
    }

}
