import Foundation

@testable import govuk_ios

class MockUserService: UserServiceInterface {
    var _stubbedNotificationsConsentStatus: ConsentStatus?
    var notificationsConsentStatus: ConsentStatus? {
        _stubbedNotificationsConsentStatus
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

}
