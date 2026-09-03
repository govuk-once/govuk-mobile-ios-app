import Foundation
import UIKit
import Qualtrics

import GovKit

protocol QualtricsServiceInterface {
    func evaluateViewEvent(
        screenName: String,
        params: [String: String]
    ) async
    func evaluateEvent(
        params: [String: String]
    ) async
}

actor QualtricsService: QualtricsServiceInterface {
    private let brandId: String
    private let projectId: String
    private let qualtrics: QualtricsWrapperInterface
    // presentationController is for testing only
    private let presentationController: UIViewController?
    private let firebaseIDsService: FirebaseIDsServiceInterface
    private let firebaseClient: AnalyticsClient

    @MainActor
    private var surveyController: UIViewController? {
        if let viewController = presentationController {
            return viewController
        }
        let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?
            .delegate as? SceneDelegate
        guard let sceneDelegate = sceneDelegate,
              let window = sceneDelegate.window,
              let root = window.rootViewController else { return nil }
        return root.topController
    }

    init(
        brandId: String,
        projectId: String,
        qualtrics: QualtricsWrapperInterface,
        firebaseIDsService: FirebaseIDsServiceInterface,
        firebaseClient: AnalyticsClient,
        theme: QualtricsTheme? = nil,
        completion: QualtricsInitializationResult? = nil,
        presentationController: UIViewController? = nil
    ) {
        self.brandId = brandId
        self.projectId = projectId
        self.qualtrics = qualtrics
        self.firebaseIDsService = firebaseIDsService
        self.firebaseClient = firebaseClient
        self.presentationController = presentationController
        qualtrics.initializeProject(
            brandId: brandId,
            projectId: projectId,
            extRefId: nil,
            completion: completion
        )
        if let theme {
            qualtrics.setCreativeTheme(to: theme)
        }
    }

    func evaluateViewEvent(
        screenName screen: String,
        params: [String: String]
    ) async {
        qualtrics.registerViewVisit(viewName: screen)
        await evaluate(params: params)
    }

    func evaluateEvent(params: [String: String]) async {
        await evaluate(params: params)
    }

    private func evaluate(params: [String: String]) async {
        setQualtricsProperties(params)
        await evaluateTargets { id, result in
            guard result.passed(),
                  let viewController = await surveyController
            else { return }

            trackSurveyOpened(targetingID: id)

            if let url = result.getSurveyUrl() {
                let urlComponents = URLComponents(string: url)
                let hidePrompt = urlComponents?.caseInsensitiveQueryParam(for: "hide_prompt")
                let autoClose = urlComponents?.caseInsensitiveQueryParam(for: "auto_close")
                let autoCloseSurvey = autoClose == "true" ? true : false

                if hidePrompt == "true" {
                    result.recordImpression()
                    await openSurveyByUrl(
                        url,
                        viewController: viewController,
                        autoCloseSurvey: autoCloseSurvey
                    )
                    return
                }
            }

            _ = qualtrics.display(
                viewController: viewController,
                autoCloseSurvey: false
            )
        }
    }

    private func openSurveyByUrl(
        _ url: String,
        viewController: UIViewController,
        autoCloseSurvey: Bool
    ) async {
        await MainActor.run {
            let surveyController = QualtricsSurveyViewController(
                url: url,
                autoCloseSurvey: NSNumber(value: autoCloseSurvey)
            )
            surveyController.modalPresentationStyle = .overFullScreen
            viewController.present(surveyController, animated: true)
        }
    }

    private func evaluateTargets(
        onPass: (String, TargetingResultInterface) async -> Void
    ) async {
        if let (id, res) = await withCheckedContinuation({ cont in
            qualtrics.evaluateProjectTargets { results in
                cont.resume(returning: results.first { $0.value.passed() })
            }
        }) {
            await onPass(id, res)
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
    ) -> [String: String] {
        var newParameters = [String: String]()
        analyticsParameterKeys.forEach { key in
            newParameters[key] = parameters[key] ?? ""
        }
        return newParameters
    }

    private func setQualtricsProperties(_ params: [String: String]) {
        let qualtricsParams = qualtricsParams(from: params)
        for (key, value) in qualtricsParams {
            qualtrics.setString(string: value, for: key)
        }

        qualtrics.setString(
            string: firebaseIDsService.appInstanceID,
            for: "fb_user_pseudo_id"
        )
        qualtrics.setString(
            string: firebaseIDsService.sessionID,
            for: "fb_session_id"
        )
        // Refreshes session ID as could change, async so called post set.
        firebaseIDsService.updateSessionID()
    }

    private func trackSurveyOpened(targetingID: String) {
        firebaseClient.track(
            event: AppEvent(
                name: "qualtrics_survey_opened",
                params: [
                    "qualtrics_targeting_id": targetingID
                ]
            )
        )
    }
}
