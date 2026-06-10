import Foundation
import UIKit
import Qualtrics

protocol QualtricsServiceInterface {
    func evaluateViewEvent(
        screenName: String,
        params: [String: String]
    ) async
    func evaluateClickEvent(params: [String: String]) async
}

struct QualtricsService: QualtricsServiceInterface {
    private let brandId: String
    private let projectId: String
    private let qualtrics: QualtricsWrapperInterface
    // presentationController is for testing only
    private let presentationController: UIViewController?
    private let firebaseAnalytics: FirebaseAnalyticsInterface.Type

    private var surveyController: UIViewController? {
        if let controller = presentationController {
            return controller
        }
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
        qualtrics: QualtricsWrapperInterface,
        firebaseAnalytics: FirebaseAnalyticsInterface.Type,
        completion: QualtricsInitializationResult? = nil,
        presentationController: UIViewController? = nil
    ) {
        self.brandId = brandId
        self.projectId = projectId
        self.qualtrics = qualtrics
        self.firebaseAnalytics = firebaseAnalytics
        self.presentationController = presentationController
        qualtrics.initializeProject(
            brandId: brandId,
            projectId: projectId,
            extRefId: nil,
            completion: completion
        )
    }

    func evaluateViewEvent(
        screenName: String,
        params: [String: String]
    ) async {
        await setQualtricsProperties(params)
        qualtrics.registerViewVisit(viewName: screenName)
        qualtrics.evaluateProjectTargets { targetingResults in
            guard targetingResults.first(
                where: { result in
                    result.value.passed()
                }
            ) != nil,
                  let surveyController else { return }

            _ = qualtrics.display(
                viewController: surveyController,
                autoCloseSurvey: false
            )
        }
    }

    func evaluateClickEvent(params: [String: String]) async {
        await setQualtricsProperties(params)
        qualtrics.evaluateProjectTargets { targetingResults in
            guard let targetingResultDict = targetingResults.first(
                where: { result in
                    result.value.passed()
                }
            ),
                  let url = targetingResultDict.value.getSurveyUrl(),
                  let surveyController else { return }

            targetingResultDict.value.recordImpression()
            Task { @MainActor in
                // We are assuming the user clicked on a "Give feedback" button
                // or other CTA that informs a survey is about to be presented,
                // so we diplay the survey directly without the intitial prompt
                let qualtricsController = QualtricsSurveyViewController(url: url)
                qualtricsController.modalPresentationStyle = .overFullScreen
                surveyController.present(qualtricsController, animated: true)
            }
        }
    }

    /**
     * The Qualtrics SDK data storage mechanism is implemented as a single (flat) map
     * that is cached across events.  As a consequence, if a key is not overwritten in
     * newer events it will be resent in subsequent events, causing incorrect event data to
     * be 'leaked' across events.
     *
     * This seems to be a deliberate 'feature'.
     *
     * To date, the only solution to this seems to be creating a unique, defined and
     * distinct set of keys that are set to the new events value or an empty string
     * before being sent. It seems this is the only way to ensure that only valid
     * data is sent.
     */
    private let analyticsParameterKeys = [
        "action",
        "external",
        "item_list_id",
        "item_list_name",
        "language",
        "screen_class",
        "screen_name",
        "screen_title",
        "section",
        "text",
        "type",
        "url"
    ]

    private func qualtricsParams(
        from parameters: [String: String]
    ) async -> [String: String] {
        var newParameters = [String: String]()
        analyticsParameterKeys.forEach { key in
            newParameters[key] = parameters[key] ?? ""
        }
        return newParameters
    }

    private func setQualtricsProperties(_ params: [String: String]) async {
        let qualtricsParams = await qualtricsParams(from: params)
        for (key, value) in qualtricsParams {
            qualtrics.setString(string: value, for: key)
        }
        var gaSessionId = ""
        if let sessionId = try? await firebaseAnalytics.sessionID() {
            gaSessionId = "\(sessionId)"
        }
        qualtrics.setString(string: gaSessionId, for: "ga_session_id")
        let appInstanceId = firebaseAnalytics.appInstanceID()
        qualtrics.setString(string: appInstanceId ?? "", for: "ga_app_instance_id")
    }
}
