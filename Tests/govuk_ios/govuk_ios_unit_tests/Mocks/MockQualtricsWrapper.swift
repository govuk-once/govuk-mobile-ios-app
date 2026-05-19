import Foundation
import UIKit
import Qualtrics

@testable import govuk_ios

class MockQualtricsWrapper: QualtricsWrapperInterface {
    var _didInitializeProject = false
    func initializeProject(
        brandId: String,
        projectId: String,
        extRefId: String?,
        completion: QualtricsInitializationResult?
    ) {
        _didInitializeProject  = true
    }

    var _didEvaluateProject = false
    var _stubbedTargetingResults: [String: TargetingResultInterface] = [:]
    func evaluateProjectTargets(completion: @escaping ([String: any TargetingResultInterface]) -> Void) {
        _didEvaluateProject = true
        completion(_stubbedTargetingResults)
    }

    var _didDisplayViewController = false
    func display(viewController: UIViewController, autoCloseSurvey: NSNumber) -> Bool {
        _didDisplayViewController = true
        return true
    }

    var _didRegisterViewVisit = false
    func registerViewVisit(viewName: String) {
        _didRegisterViewVisit = true
    }

    var properties: [String: String] = [:]
    func setString(string value: String, for key: String) {
        properties[key] = value
    }
}

class MockTargetingResult: TargetingResultInterface {
    var _stubbedTargetPassed: Bool = false
    func passed() -> Bool {
        return _stubbedTargetPassed
    }

    var _stubbedSurveyUrl: String?
    func getSurveyUrl() -> String? {
        _stubbedSurveyUrl
    }

    var _didRecordImpression = false
    func recordImpression() {
        _didRecordImpression = true
    }
}
