import Foundation
import GovKit
import GovKitUI

class TermsAndConditionsViewModel: InfoViewModelInterface {
    var analyticsService: AnalyticsServiceInterface?
    private var updatedTermsAndConditions: Bool
    private var completionAction: () -> Void
    private var dismissAction: () -> Void
    private var openURLAction: (URL) -> Void

    init(analyticsService: AnalyticsServiceInterface,
         updatedTermsAndConditions: Bool,
         completionAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void,
         openURLAction: @escaping (URL) -> Void
    ) {
        self.analyticsService = analyticsService
        self.updatedTermsAndConditions = updatedTermsAndConditions
        self.completionAction = completionAction
        self.dismissAction = dismissAction
        self.openURLAction = openURLAction
    }

    var visualAssetContent: VisualAssetContent {
        VisualAssetContent.decorativeImage("TermsAndConditions")
    }

    var trackingName: String {
        "Terms and conditions"
    }

    var trackingTitle: String {
        title
    }

    var title: String {
        let titleVariant = updatedTermsAndConditions ?
        LocalizedStringResource.TermsAndConditions.updatedTermsAndConditionsTitle :
        LocalizedStringResource.TermsAndConditions.newTermsAndConditionsTitle
        return String(localized: titleVariant)
    }

    var primaryButtonTitle: String {
        String(localized: .TermsAndConditions.termsAndConditionsPrimaryButtonTitle)
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.completionAction()
            }
        )
    }

    var secondaryButtonTitle: String {
        String(localized: .TermsAndConditions.termsAndConditionsSecondaryButtonTitle)
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel? {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                self?.dismissAction()
            }
        )
    }
}
