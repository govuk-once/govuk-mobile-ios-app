import Foundation
import Testing

@testable import govuk_ios

class MockFirebaseAnalytics: FirebaseAnalyticsInterface {
    static var _stubbedAppInstanceId: String?
    static func appInstanceID() -> String? {
        _stubbedAppInstanceId
    }

    static var _stubbedSessionId: Int64?
    static func sessionID() async throws -> Int64 {
        guard let sessionId = _stubbedSessionId else {
            throw TestError.anyError
        }
        return sessionId
    }

    static func clearValues() {
        _setAnalyticsCollectionEnabledReveivedEnabled = nil
        _logEventReceivedEventName = nil
        _logEventReceivedEventParameters = nil
        _setUserPropertyReveivedName = nil
        _setUserPropertyReveivedValue = nil
    }

    static var _setAnalyticsCollectionEnabledReveivedEnabled: Bool?
    static func setAnalyticsCollectionEnabled(_ newValue: Bool) {
        _setAnalyticsCollectionEnabledReveivedEnabled = newValue
    }

    static var _logEventReceivedEventName: String?
    static var _logEventReceivedEventParameters: [String : Any]?
    static func logEvent(_ eventName: String,
                         parameters: [String : Any]?) {
        _logEventReceivedEventName = eventName
        _logEventReceivedEventParameters = parameters
    }

    static var _setUserPropertyReveivedValue: String?
    static var _setUserPropertyReveivedName: String?
    static func setUserProperty(_ value: String?,
                                forName name: String) {
        _setUserPropertyReveivedValue = value
        _setUserPropertyReveivedName = name
    }
}
