import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class ServiceAccountConsentViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceInterface
    private let accountType: ServiceAccountType
    private let completionAction: () -> Void
    private let cancelAction: () -> Void

    init(analyticsService: AnalyticsServiceInterface,
         accountType: ServiceAccountType,
         completionAction: @escaping () -> Void,
         cancelAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.accountType = accountType
        self.completionAction = completionAction
        self.cancelAction = cancelAction
    }

    private var accountName: String {
        accountType == .dvla ? String.dvla.localized("accountName") : ""
    }

    var title: String {
        let format = String.serviceAccount.localized("linkAccountFullScreenTitle")
        return String.localizedStringWithFormat(format, accountName)
    }

    var descriptionTop: String {
        accountType == .dvla
        ? String.dvla.localized("linkAccountFullScreenDescriptionTop")
        : ""
    }

    var descriptionBottom: String {
        String.serviceAccount.localized("linkAccountFullScreenDescriptionBottom")
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

    var closeButtonAccessibilityLabel: String {
        String.common.localized("close")
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

    private func trackCompletionAction() {
        let event = AppEvent.buttonNavigation(
            text: primaryButtonTitle,
            external: false,
            section: "continue"
        )
        analyticsService.track(event: event)
    }

    private func trackCancelAction() {
        let event = AppEvent.navigation(
            text: "N/A",
            type: "Close",
            external: false
        )
        analyticsService.track(event: event)
    }

    @objc
    func cancel() {
        trackCancelAction()
        cancelAction()
    }
}
