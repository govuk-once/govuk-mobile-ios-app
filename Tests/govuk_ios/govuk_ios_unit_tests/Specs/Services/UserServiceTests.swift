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
        mockAppConfigService.features = [.profile]
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)
        mockUserServiceClient._stubbedFetchUserStateResult = .success(UserState.arrange)

        let result = await withCheckedContinuation { continuation in
            sut.fetchUserState(completion: {
                continuation.resume(returning: $0)
            })
        }

        let userStateResponse = try #require(try? result.get())
        #expect(userStateResponse.notifications.pushId == "push_id")

    }

    @Test
    func fetchUserState_returnsExpectedError() async throws {
        mockAppConfigService.features = [.profile]
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
        mockAppConfigService.features = [.profile]
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

    /// Temporarily disable sending of consent
    /// https://govukverify.atlassian.net/browse/GOVUKAPP-3485
    @Test
    func setNotificationConsent_flexEnabled_doesNotCallClient() {
        mockAppConfigService.features = [.profile]
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)

        sut.setNotificationsConsent(.accepted)
        #expect(mockUserServiceClient._receivedNotificationConsent ==  nil)
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
    func fetchUserState_updatesPushId() async throws {
        mockAppConfigService.features = [.profile]
        let userService = UserService(appConfigService: mockAppConfigService,
                                      userServiceClient: mockUserServiceClient)
        mockUserServiceClient._stubbedFetchUserStateResult = .success(UserState.arrange(pushId: "push-id-1"))

        userService.fetchUserState { _ in }
        
        #expect(userService.pushId == "push-id-1")
    }

    @Test
    func linkAccount_success_returnsExpectedResult() {
        mockUserServiceClient._stubbedLinkAccountResult = .success(())
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)
        var wasSuccessful = false
        sut.linkAccount(withType: .dvla,
                        linkId: "test-link-id") { result in
            switch result {
            case .success:
                wasSuccessful = true
            case .failure:
                Issue.record("Expected success")
            }
        }
        #expect(wasSuccessful == true)
    }

    @Test
    func linkAccount_failure_returnsExpectedError() {
        mockUserServiceClient._stubbedLinkAccountResult = .failure(
            UserStateError.authenticationError
        )
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)
        sut.linkAccount(withType: .dvla,
                        linkId: "test-link-id") { result in
            #expect(result.getError() == .authenticationError)
        }
    }

    @Test
    func linkAccount_success_updatesIdDvlaAccountLinked() {
        mockUserServiceClient._stubbedLinkAccountResult = .success(())
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)
        #expect(sut.isDvlaAccountLinked == false)

        sut.linkAccount(withType: .dvla, linkId: "test-link-id") { _ in
            #expect(sut.isDvlaAccountLinked == true)
        }
    }

    @Test
    func unlinkAccount_success_returnsExpectedResult() {
        mockUserServiceClient._stubbedUnlinkAccountResult = .success(())
        let sut = UserService(appConfigService: mockAppConfigService,
                              userServiceClient: mockUserServiceClient)
        var wasSuccessful = false
        sut.unlinkAccount(withType: .dvla) { result in
            if case .success = result {
                wasSuccessful = true
            }
            #expect(wasSuccessful == true)
        }
    }

    @Test
    func unlinkAccount_failure_returnsExpectedError() {
        mockUserServiceClient._stubbedUnlinkAccountResult = .failure(
            UserStateError.apiUnavailable
        )
        let sut =  UserService(appConfigService: mockAppConfigService,
                               userServiceClient: mockUserServiceClient)
        sut.unlinkAccount(withType: .dvla) { result in
            #expect(result.getError() == .apiUnavailable)
        }
    }

    @Test
    func fetchAccountLinkStatus_success_returnsExpectedResult() async {
        mockUserServiceClient._stubbedFetchAccountLinkStatusResult = .success(
            .arrangeUnlinked
        )
        let sut = UserService(
            appConfigService: mockAppConfigService,
            userServiceClient: mockUserServiceClient
        )
        let result = await sut.fetchAccountLinkStatus(
            accountType: .dvla
        )
        let accountLinkStatus = try? result.get()
        #expect(accountLinkStatus?.linked == false)
    }

    @Test
    func fetchAccountLinkStatus_apiUnavailable_returnsExpectedError() async {
        mockUserServiceClient._stubbedFetchAccountLinkStatusResult = .failure(
            .apiUnavailable
        )
        let sut = UserService(
            appConfigService: mockAppConfigService,
            userServiceClient: mockUserServiceClient
        )
        let result = await sut.fetchAccountLinkStatus(
            accountType: .dvla
        )
        #expect(result.getError() == .apiUnavailable)
    }
}
