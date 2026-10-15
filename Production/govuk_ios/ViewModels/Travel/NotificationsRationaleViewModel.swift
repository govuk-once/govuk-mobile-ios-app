import Foundation
import UIKit
import GovKit
import GovKitUI

typealias NotificationsRationaleSaveAction = (
    _ notificationsEnabled: Bool,
    _ completion: @escaping (Result<Void, TravelError>) -> Void
) -> Void

enum NotificationsRationaleDeclineBehaviour {
    case saveDisabled
    case report(() -> Void)
}

enum NotificationsRationaleOrigin: String {
    case FOLLOW
    case EDIT
}

class NotificationsRationaleViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
    }

    @Published private(set) var viewState: ViewState = .idle
    @Published var displayNotificationSettingsAlert: Bool = false

    private let notificationService: NotificationServiceInterface
    private let urlOpener: URLOpener
    private let notificationCenter: NotificationCenter
    private let saveAction: NotificationsRationaleSaveAction
    private let declineBehaviour: NotificationsRationaleDeclineBehaviour
    let analyticsService: AnalyticsServiceInterface
    let dismissSheetAction: () -> Void
    let openExternalURLAction: (URL) -> Void
    let showImage: Bool

    let title: String = String(localized: .Travel.travelAlertPermissionTitle)
    let body: String = String(localized: .Travel.travelAlertPermissionDescription)
    let primaryButtonTitle: String = String(localized: .Travel.travelAlertPermissionPrimaryButton)
    let secondaryButtonTitle: String = String(
        localized: .Travel.travelAlertPermissionSecondaryButton
    )
    let privacyPolicyLinkTitle: String = String(
        localized: .Travel.travelAlertPermissionPrivacyButtonTitle
    )

    var notificationSettingsAlertTitle: String {
        String(localized: .Settings.notificationsAlertTitleDisabled)
    }

    var notificationSettingsAlertBody: String {
        String(localized: .Settings.notificationsAlertBodyDisabled)
    }

    var notificationAlertButtonTitle: String {
        String(localized: .Settings.notificationAlertPrimaryButtonTitle)
    }

    var notificationAlertSecondaryButtonTitle: String {
        String(localized: .Travel.countryListAlertCancel)
    }

    private var dismissAfterSuccessAction: (() -> Void)?
    private var dismissAfterErrorAction: (() -> Void)?
    private var isPendingPermissionCheck: Bool = false
    private let origin: NotificationsRationaleOrigin

    init(
        notificationService: NotificationServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        urlOpener: URLOpener,
        notificationCenter: NotificationCenter = .default,
        showImage: Bool = true,
        saveAction: @escaping NotificationsRationaleSaveAction,
        declineBehaviour: NotificationsRationaleDeclineBehaviour,
        dismissSheetAction: @escaping () -> Void,
        openExternalURLAction: @escaping (URL) -> Void,
        dismissAfterSuccessAction: @escaping () -> Void,
        dismissAfterErrorAction: @escaping () -> Void,
        origin: NotificationsRationaleOrigin = .FOLLOW
    ) {
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.notificationCenter = notificationCenter
        self.showImage = showImage
        self.saveAction = saveAction
        self.declineBehaviour = declineBehaviour
        self.dismissSheetAction = dismissSheetAction
        self.openExternalURLAction = openExternalURLAction
        self.dismissAfterSuccessAction = dismissAfterSuccessAction
        self.dismissAfterErrorAction = dismissAfterErrorAction
        self.origin = origin
        observeAppMoveToForeground()
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                guard let self else { return }
                self.allowNotificationsAction()
            }
        )
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                guard let self else { return }
                self.notNowAction()
            }
        )
    }

    func viewDidAppear() {
        analyticsService.track(
            event: AppEvent(
                name: "notifications_rationale_view",
                params: ["origin": origin.rawValue]
            )
        )
    }


    func allowNotificationsAction() {
        analyticsService.track(
            event: AppEvent(
                name: "notifications_rationale_agree",
                params: ["origin": origin.rawValue]
            )
        )
        Task {
            let permissionState = await notificationService.permissionState
            await MainActor.run {
                switch permissionState {
                case .authorized:
                    self.notificationService.acceptConsent()
                    self.save(notificationsEnabled: true)
                case .denied:
                    self.displayNotificationSettingsAlert = true
                case .notDetermined:
                    self.requestNotificationPermission()
                }
            }
        }
    }

    private func requestNotificationPermission() {
        notificationService.requestPermissions { [weak self] granted in
            Task { @MainActor in
                self?.save(notificationsEnabled: granted)
            }
        }
    }

    func notNowAction() {
        analyticsService.track(
            event: AppEvent(
                name: "notifications_rationale_not_now",
                params: ["origin": origin.rawValue]
            )
        )
        decline()
    }

    private func decline() {
        switch declineBehaviour {
        case .saveDisabled:
            save(notificationsEnabled: false)
        case .report(let onDeclined):
            onDeclined()
        }
    }

    private func save(notificationsEnabled: Bool) {
        viewState = .loading
        saveAction(notificationsEnabled) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.viewState = .idle
                    self?.dismissAfterSuccessAction?()
                case .failure:
                    self?.dismissAfterErrorAction?()
                }
            }
        }
    }

    func openPrivacyPolicy() {
        let privacyPolicyURL = URL(string: Constants.API.privacyPolicyUrl.absoluteString)
        if let url = privacyPolicyURL {
            openExternalURLAction(url)
        }
    }

    func onSettingsAlertContinueAction() {
        analyticsService.track(
            event: AppEvent(
                name: "notifications_rationale_settings_continue",
                params: ["origin": origin.rawValue]
            )
        )
        if urlOpener.openNotificationSettings() {
            isPendingPermissionCheck = true
        }
    }

    func onSettingsAlertCancelAction() {
        analyticsService.track(
            event: AppEvent(
                name: "notifications_rationale_settings_cancel",
                params: ["origin": origin.rawValue]
            )
        )
        decline()
    }

    private func observeAppMoveToForeground() {
        notificationCenter.addObserver(
            self,
            selector: #selector(retryPermissionCheckAfterSettings),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc
    private func retryPermissionCheckAfterSettings() {
        guard isPendingPermissionCheck else { return }

        Task {
            let permissionState = await notificationService.permissionState
            await MainActor.run {
                switch permissionState {
                case .authorized:
                    self.notificationService.acceptConsent()
                    self.isPendingPermissionCheck = false
                    self.displayNotificationSettingsAlert = false
                    self.save(notificationsEnabled: true)
                case .denied, .notDetermined:
                    self.isPendingPermissionCheck = false
                    self.displayNotificationSettingsAlert = false
                }
            }
        }
    }
}
