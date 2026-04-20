import Foundation
import Testing

@testable import govuk_ios

@Suite
final class UserServiceTests {
    var mockUserServiceClient: MockUserServiceClient!
    var mockAppConfigService: MockAppConfigService!

    init() {
        mockUserServiceClient = MockUserServiceClient()
        mockAppConfigService = MockAppConfigService()
    }

    @Test
    func fetchUserState_returnsExpectedValue() async throws {
        mockAppConfigService.features = [.flex]
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)
        mockUserServiceClient._stubbedFetchUserStateResult = .success(UserState.arrange)

        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState(completion: {
                continuation.resume(returning: $0)
            })
        }

        let userStateResponse = try #require(try? result.get())
        #expect(userStateResponse.notifications.pushId == "notification_id")

    }

    @Test
    func fetchUserState_returnsExpectedError() async throws {
        mockAppConfigService.features = [.flex]
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)

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
        mockAppConfigService.features = [.flex]
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)

        mockUserServiceClient?._stubbedFetchUserStateResult = .success(UserState.arrangeAccepted)
        await withCheckedContinuation { continuation in
            sut.fetchUserState(completion: { _ in
                continuation.resume()
            })
        }

        #expect(sut.notificationsConsentStatus == .accepted)
    }

    @Test
    func setNotificationConsent_flexEnabled_callsClient() {
        mockAppConfigService.features = [.flex]
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)

        sut.setNotificationsConsent(.accepted)
        #expect(mockUserServiceClient._receivedNotificationConsent == .accepted)
    }

    @Test
    func setNotificationConsent_flexDisabled_doesNotCallClient() {
        mockAppConfigService.features = []
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)

        sut.setNotificationsConsent(.accepted)
        #expect(mockUserServiceClient._receivedNotificationConsent == nil)
    }
    
    @Test
    func fetchUserState_updatesNotificationId() async throws {
        mockAppConfigService.features = [.flex]
        let userService = UserService(appConfigService: mockAppConfigService,
                                      userServiceClient: mockUserServiceClient)
        mockUserServiceClient._stubbedFetchUserStateResult = .success(UserState.arrange(notificationId: "notification-id-1"))
        
        userService.fetchUserState { _ in }
        
        #expect(userService.notificationId == "notification-id-1")
    }

}
