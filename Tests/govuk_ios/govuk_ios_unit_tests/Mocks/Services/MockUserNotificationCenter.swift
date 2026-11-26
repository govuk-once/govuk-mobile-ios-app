import Foundation
import UserNotifications

@testable import govuk_ios

class MockUserNotificationCenter: UserNotificationCenterInterface {

    var _stubbedAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    open var authorizationStatus: UNAuthorizationStatus {
        get async {
            _stubbedAuthorizationStatus
        }
    }

    var _stubbedRequestAuthorizationResult: Bool = false
    var _stubbedRequestAuthorizationError: Error?
    var _receivedRequestAuthorizationOptions: UNAuthorizationOptions?
    var _requestAuthorizationAction: (() -> Void)?
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        _receivedRequestAuthorizationOptions = options
        _requestAuthorizationAction?()
        if let error = _stubbedRequestAuthorizationError {
            throw error
        }
        return _stubbedRequestAuthorizationResult
    }

}
