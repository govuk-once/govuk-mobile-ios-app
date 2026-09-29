import Foundation
import GovKit
import GovKitUI

class TravelAlertsPermissionViewModel: ObservableObject {
    let analyticsService: AnalyticsServiceInterface
    let completeAction: () -> Void
    let dismissAction: () -> Void
    let showImage: Bool

    let title: String
    let body: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String

    init(analyticsService: AnalyticsServiceInterface,
         showImage: Bool = true,
         title: String,
         body: String,
         primaryButtonTitle: String,
         secondaryButtonTitle: String,
         completeAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.showImage = showImage
        self.title = title
        self.body = body
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.completeAction = completeAction
        self.dismissAction = dismissAction
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.trackButtonActionEvent(title: self?.primaryButtonTitle ?? "")
                self?.completeAction()
            }
        )
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                self?.trackButtonActionEvent(title: self?.secondaryButtonTitle ?? "")
                self?.dismissAction()
            }
        )
    }

    private func trackButtonActionEvent(title: String) {
        let event = AppEvent.buttonNavigation(text: title, external: false)
        analyticsService.track(event: event)
    }
}
