import Foundation

@testable import govuk_ios

class MockUserService: UserServiceInterface {
    var isEnabled: Bool { true }
    var _stubbedNotificationsConsentStatus: ConsentStatus?
    var notificationsConsentStatus: ConsentStatus? {
        _stubbedNotificationsConsentStatus
    }
    var _stubbedNotificationId: String?
    var notificationId: String? {
        _stubbedNotificationId
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
}
