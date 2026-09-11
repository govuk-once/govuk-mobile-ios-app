import Qualtrics
import UIKit

typealias QualtricsInitializationResult = ([String: InitializationResult]) -> Void

protocol QualtricsWrapperInterface {
    func initializeProject(
        brandId: String,
        projectId: String,
        extRefId: String?,
        completion: QualtricsInitializationResult?
    )
    func display(
        viewController: UIViewController,
        autoCloseSurvey: NSNumber
    ) -> Bool
    func evaluateProjectTargets(
        completion: @escaping ([String: TargetingResultInterface]) -> Void)
    func registerViewVisit(viewName: String)
    func setString(string: String, for: String)
    // swiftlint:disable:next identifier_name
    func setCreativeTheme(to: QualtricsTheme)
}

extension Qualtrics: QualtricsWrapperInterface {
    func setString(string value: String, for key: String) {
        Self.shared.properties.setString(string: value, for: key)
    }

    func evaluateProjectTargets(
        completion: @escaping ([String: TargetingResultInterface]) -> Void
    ) {
        Self.shared.evaluateProject { targetingResults in
            let transformedResults = targetingResults
                .compactMapValues( { $0 as TargetingResultInterface })
            completion(transformedResults)
        }
    }
}

protocol TargetingResultInterface {
    func passed() -> Bool
    func getSurveyUrl() -> String?
    func recordImpression()
}

extension TargetingResult: TargetingResultInterface {}
