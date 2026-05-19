import Foundation

@testable import govuk_ios

class MockQualtricsService: QualtricsServiceInterface {
    var _didCallEvaluateViewEvent = false
    var _stubbedScreenName: String?
    var _stubbedViewParams: [String: String]?
    func evaluateViewEvent(screenName: String, params: [String : String]) {
        _didCallEvaluateViewEvent = true
        _stubbedScreenName = screenName
        _stubbedViewParams = params
    }

    var _didCallEvaluateClickEvent = false
    var _stubbedClickParams: [String: String]?
    func evaluateClickEvent(params: [String : String]) {
        _didCallEvaluateClickEvent = true
        _stubbedClickParams = params
    }
}

