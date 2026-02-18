import Foundation

@testable import govuk_ios

class MockUserServiceClient: UserServiceClientInterface {

    var _stubbedFetchUserStateResult: UserStateResult?
    func fetchUserState(completion: @escaping FetchUserStateCompletion) {
        if let result = _stubbedFetchUserStateResult {
            completion(result)
        }
    }

    var _receivedNotificationConsent: ConsentStatus?
    func setNotificationsConsent(_ consentStatus: ConsentStatus, completion: @escaping (NotificationsPreferenceResult) -> Void) {
        _receivedNotificationConsent = consentStatus
    }

}

