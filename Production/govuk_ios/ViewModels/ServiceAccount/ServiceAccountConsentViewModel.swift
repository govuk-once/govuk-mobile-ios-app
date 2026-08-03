import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class ServiceAccountConsentViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceInterface
    private let notificationCenter: NotificationCenter
    private let accountType: ServiceAccountType
    private let completionAction: () -> Void
    private let cancelAction: () -> Void

    private var didBecomeActiveObserverToken: Any?
    private var isPrimaryButtonEnabled: Bool = true

    init(analyticsService: AnalyticsServiceInterface,
         notificationCenter: NotificationCenter = .default,
         accountType: ServiceAccountType,
         completionAction: @escaping () -> Void,
         cancelAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.notificationCenter = notificationCenter
        self.accountType = accountType
        self.completionAction = completionAction
        self.cancelAction = cancelAction
        observeDidBecomeActive()
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
                guard self?.isPrimaryButtonEnabled == true else {
                    return
                }
                self?.isPrimaryButtonEnabled = false
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

    private func observeDidBecomeActive() {
        didBecomeActiveObserverToken = notificationCenter.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.isPrimaryButtonEnabled = true
            }
        )
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
