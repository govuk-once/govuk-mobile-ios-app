import Foundation
import UIKit
import Qualtrics

protocol QualtricsServiceInterface {
    func evaluateViewEvent(
        screenName: String,
        params: [String: String]
    )
    func evaluateClickEvent(params: [String: String])
}

protocol QualtricsWrapperInterface {
    static var shared: Qualtrics { get }
    func evaluateProject(
        completion: @escaping (
            _ targetingResults: [String: TargetingResult]
        ) -> Void
    )
    func initializeProject(
        brandId: String,
        projectId: String,
        extRefId: String?,
        completion: (
            (
                _ initializationResults: [String: InitializationResult]
            ) -> Void
        )?
    )
    func display(
        viewController: UIViewController,
        autoCloseSurvey: NSNumber
    ) -> Bool
    func registerViewVisit(viewName: String)
    var properties: QualtricsProperties { get }
}

struct QualtricsService: QualtricsServiceInterface {
    private let brandId: String
    private let projectId: String
    private let qualtrics: QualtricsWrapperInterface

    private var surveyController: UIViewController? {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?
            .delegate as? SceneDelegate,
                let window = sceneDelegate.window,
              let root = window.rootViewController else { return nil }
        return root.topController
    }

    init(
        brandId: String,
        projectId: String,
        qualtrics: QualtricsWrapperInterface
    ) {
        self.brandId = brandId
        self.projectId = projectId
        self.qualtrics = qualtrics
        qualtrics.initializeProject(
            brandId: brandId,
            projectId: projectId,
            extRefId: nil) { result in
                print(result.debugDescription)
            }
    }

    func evaluateViewEvent(
        screenName: String,
        params: [String: String]
    ) {
        for (key, value) in params {
            qualtrics.properties.setString(string: value, for: key)
        }

        qualtrics.registerViewVisit(viewName: screenName)
        qualtrics.evaluateProject { targetingResults in
            if targetingResults.contains(where: { (_: String, value: TargetingResult) in
                value.passed()
            }) {
                guard let surveyController else { return }
                _ = qualtrics.display(
                    viewController: surveyController,
                    autoCloseSurvey: false
                )
            }
        }
    }

    func evaluateClickEvent(params: [String: String]) {
        for (key, value) in params {
            qualtrics.properties.setString(string: value, for: key)
        }
        qualtrics.evaluateProject { targetingResults in
            guard let targetingResult = targetingResults.first(
                where: { (_: String, value: TargetingResult) in
                    value.passed()
                }
            ),
            let url = targetingResult.value.getSurveyUrl(),
            let surveyController else { return }
            targetingResult.value.recordImpression()
            Task { @MainActor in
                let qualtricsController = QualtricsSurveyViewController(url: url)
                qualtricsController.modalPresentationStyle = .overFullScreen
                surveyController.present(qualtricsController, animated: true)
            }
        }
    }
}

extension Qualtrics: QualtricsWrapperInterface { }
