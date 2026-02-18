import Foundation
import GovKit
import GovKitUI

class TermsAndConditionsViewModel: ObservableObject {
    private let termsAndConditionsService: TermsAndConditionsServiceInterface
    private let completionAction: () -> Void
    private let alertDismissAction: () -> Void
    private let openURLAction: (URL) -> Void
    @Published var showAlert = false

    init(termsAndConditionsService: TermsAndConditionsServiceInterface,
         completionAction: @escaping () -> Void,
         alertDismissAction: @escaping () -> Void,
         openURLAction: @escaping (URL) -> Void
    ) {
        self.termsAndConditionsService = termsAndConditionsService
        self.completionAction = completionAction
        self.alertDismissAction = alertDismissAction
        self.openURLAction = openURLAction
    }

    var alertDetails: AlertDetails {
        AlertDetails(
            title: String(
                localized: .TermsAndConditions.termsAndConditionsTitle
            ),
            message: String(
                localized: .TermsAndConditions.alertDescription
            ),
            primaryButtonTitle: String(
                localized: .TermsAndConditions.alertPrimaryButtonTitle
            ),
            secondaryButtonTitle: String(
                localized: .TermsAndConditions.alertSecondaryButtonTitle
            ),
            secondaryButtonAction: alertDismissAction
        )
    }

    var title: String {
        let titleVariant = termsAndConditionsService.hasUpdatedTerms ?
        LocalizedStringResource.TermsAndConditions.updatedTitle :
        LocalizedStringResource.TermsAndConditions.newTitle
        return String(localized: titleVariant)
    }

    var linkList: [LinkListItem] {
        [
            LinkListItem(
                text: String(
                    localized: .TermsAndConditions.termsAndConditionsTitle
                ),
                url: termsAndConditionsService.termsAndConditionsURL
            ),
            LinkListItem(
                text: String(
                    localized: .TermsAndConditions.privacyNoticeTitle
                ),
                url: Constants.API.privacyPolicyUrl
            )
        ]
    }

    var primaryButtonTitle: String {
        String(localized: .TermsAndConditions.primaryButtonTitle)
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.termsAndConditionsService.saveAcceptanceDate()
                self?.completionAction()
            }
        )
    }

    var secondaryButtonTitle: String {
        String(localized: .TermsAndConditions.secondaryButtonTitle)
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                self?.showAlert = true
            }
        )
    }

    func openURL(_ url: URL) {
        openURLAction(url)
    }

    struct LinkListItem {
        let text: String
        let url: URL
    }
}
