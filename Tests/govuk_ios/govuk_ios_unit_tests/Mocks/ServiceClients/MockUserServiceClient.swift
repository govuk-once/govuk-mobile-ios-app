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

    var _stubbedLinkAccountResult: LinkAccountResult?
    func linkAccount(serviceName: String,
                     linkId: String,
                     completion: @escaping (LinkAccountResult) -> Void) {
        if let result = _stubbedLinkAccountResult {
            completion(result)
        }
    }

    var _stubbedUnlinkAccountResult: UnlinkAccountResult?
    func unlinkAccount(serviceName: String,
                       completion: @escaping (UnlinkAccountResult) -> Void) {
        if let result = _stubbedUnlinkAccountResult {
            completion(result)
        }
    }
    
    var _stubbedFetchAccountLinkStatusResult: LinkStatusResult!
    func fetchAccountLinkStatus(serviceName: String) async -> LinkStatusResult {
        _stubbedFetchAccountLinkStatusResult
    }
}

