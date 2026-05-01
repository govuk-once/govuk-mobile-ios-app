import Foundation

@testable import govuk_ios

class MockUserService: UserServiceInterface {
    var _stubbedIsDvlaAccountLinked: Bool = true
    var isDvlaAccountLinked: Bool { _stubbedIsDvlaAccountLinked }

    var _stubbedIsEnabled: Bool = true
    var isEnabled: Bool { _stubbedIsEnabled }
    var _stubbedNotificationsConsentStatus: ConsentStatus?
    var notificationsConsentStatus: ConsentStatus? {
        _stubbedNotificationsConsentStatus
    }
    var _stubbedPushId: String?
    var pushId: String? {
        _stubbedPushId
    }

    var _fetchUserStateCompletionBlock: (() -> Void)?
    var _stubbedFetchUserStateResult: UserStateResult?
    func fetchUserState(completion: @escaping FetchUserStateCompletion) {
        if let result = _stubbedFetchUserStateResult {
            completion(result)
        }
        _fetchUserStateCompletionBlock?()
    }

    var _setNotificationConsentCompletionBlock: (() -> Void)?
    var _receivedNotificationConsent: ConsentStatus?
    func setNotificationsConsent(_ consentStatus: ConsentStatus) {
        _receivedNotificationConsent = consentStatus
        _setNotificationConsentCompletionBlock?()
    }

    var _linkAccountCallCount = 0
    var _stubbedLinkAccountResult: LinkAccountResult?
    func linkAccount(withType accountType: ServiceAccountType,
                     linkId: String,
                     completion: @escaping LinkAccountCompletion) {
        _linkAccountCallCount += 1
        if let result = _stubbedLinkAccountResult {
            completion(result)
        }
    }

    var _unlinkAccountCallCount = 0
    var _stubbedUnlinkAccountResult: LinkAccountResult?
    func unlinkAccount(withType accountType: ServiceAccountType,
                       completion: @escaping UnlinkAccountCompletion) {
        _unlinkAccountCallCount += 1
        if let result = _stubbedUnlinkAccountResult {
            completion(result)
        }
    }

    var _fetchAccountLinkStatusCalled = false
    var _stubbedFetchAccountLinkStatusResult: LinkStatusResult!
    func fetchAccountLinkStatus(
        accountType: ServiceAccountType
    ) async -> LinkStatusResult {
        _fetchAccountLinkStatusCalled = true
        return _stubbedFetchAccountLinkStatusResult
    }
}
