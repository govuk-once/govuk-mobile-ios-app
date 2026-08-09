import Foundation

@testable import govuk_ios

class MockQualtricsService: QualtricsServiceInterface {
    var _didCallEvaluateViewEvent = false
    var _stubbedScreenName: String?
    var _stubbedViewParams: [String: String]?
    func evaluateViewEvent(screenName: String, params: [String : String]) async {
        _didCallEvaluateViewEvent = true
        _stubbedScreenName = screenName
        _stubbedViewParams = params
    }

    var _didCallEvaluateEvent = false
    var _stubbedParams: [String: String]?
    func evaluateEvent(params: [String : String]) async {
        _didCallEvaluateEvent = true
        _stubbedParams = params
    }
}

