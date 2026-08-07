import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class ServiceAccountLinkSuccessViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceInterface
    private let accountType: ServiceAccountType
    private let completionAction: () -> Void

    init(analyticsService: AnalyticsServiceInterface,
         accountType: ServiceAccountType,
         completionAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.accountType = accountType
        self.completionAction = completionAction
    }

    private var accountName: String {
        accountType == .dvla
        ? String.dvla.localized("accountName")
        : ""
    }

    var title: String {
        let format = String.serviceAccount.localized("accountLinkSuccessTitle")
        return String.localizedStringWithFormat(format, accountName).sentenceCased()
    }

    var primaryButtonTitle: String {
        String.common.localized("continue")
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.trackCompletionAction()
                self?.completionAction()
            }
        )
    }

    @MainActor
    var primaryButtonConfiguration: GOVUKButton.ButtonConfiguration {
        .blackPrimaryButton
    }

    private func trackCompletionAction() {
        let event = AppEvent.buttonNavigation(
            text: primaryButtonTitle,
            external: false,
            section: "account link success"
        )
        analyticsService.track(event: event)
    }

    var trackingTitle: String {
        title
    }

    var trackingName: String {
        title
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}
