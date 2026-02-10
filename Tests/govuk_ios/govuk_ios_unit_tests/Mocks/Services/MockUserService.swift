import Foundation

@testable import govuk_ios

class MockUserService: UserServiceInterface {

    var _fetchUserStateCompletionBlock: (() -> Void)?
    var _stubbedFetchUserStateResult: UserStateResult?
    func fetchUserState(completion: @escaping FetchUserStateCompletion) {
        if let result = _stubbedFetchUserStateResult {
            completion(result)
        }
        _fetchUserStateCompletionBlock?()
    }

    var _receivedSetNotificationsConsentAccepted: Bool?
    func setNotificationsConsent(accepted: Bool) {
        _receivedSetNotificationsConsentAccepted = accepted
    }

    var _receivedSetAnalyticsConsentAccepted: Bool?
    func setAnalyticsConsent(accepted: Bool) {
        _receivedSetAnalyticsConsentAccepted = accepted
    }
}
