import Foundation
import GovKit
import GovKitUI

class TravelAlertsPermissionViewModel: ObservableObject {
    let analyticsService: AnalyticsServiceInterface
    let dismissSheetAction: () -> Void
    let allowNotificationsAction: () -> Void
    let notNowAction: () -> Void
    let openURLAction: (URL) -> Void
    let showImage: Bool

    let title: String
    let body: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let privacyPolicyLinkTitle: String

    init(analyticsService: AnalyticsServiceInterface,
         showImage: Bool = true,
         title: String,
         body: String,
         primaryButtonTitle: String,
         secondaryButtonTitle: String,
         privacyPolicyLinkTitle: String = String(
            localized: .Travel.travelAlertPermissionPrivacyButtonTitle
         ),
         dismissSheetAction: @escaping () -> Void,
         allowNotificationsAction: @escaping () -> Void,
         notNowAction: @escaping () -> Void,
         openURLAction: @escaping (URL) -> Void
    ) {
        self.analyticsService = analyticsService
        self.showImage = showImage
        self.title = title
        self.body = body
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.privacyPolicyLinkTitle = privacyPolicyLinkTitle
        self.dismissSheetAction = dismissSheetAction
        self.allowNotificationsAction = allowNotificationsAction
        self.notNowAction = notNowAction
        self.openURLAction = openURLAction
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.allowNotificationsAction()
            }
        )
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                self?.notNowAction()
            }
        )
    }

    func openPrivacyPolicy() {
        let privacyPolicyURL = URL(string: "govuk://app.gov.uk/web?url=\(Constants.API.privacyPolicyUrl.absoluteString)")
        if let url = privacyPolicyURL {
            openURLAction(url)
        }
    }
}
