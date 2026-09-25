import Foundation
import UIKit
import GovKit
import GovKitUI

class TravelAlertsPermissionViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
    }

    @Published private(set) var viewState: ViewState = .idle
    @Published var displayNotificationSettingsAlert: Bool = false

    private let travelService: TravelServiceInterface
    private let notificationService: NotificationServiceInterface
    private let urlOpener: URLOpener
    private let notificationCenter: NotificationCenter
    let analyticsService: AnalyticsServiceInterface
    let dismissSheetAction: () -> Void
    let openURLAction: (URL) -> Void
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

    private var countryToProcess: Country?
    private var dismissAfterSuccessAction: (() -> Void)?
    private var dismissAfterErrorAction: (() -> Void)?
    private var isPendingPermissionCheck: Bool = false

    init(
        travelService: TravelServiceInterface,
        notificationService: NotificationServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        urlOpener: URLOpener,
        showImage: Bool = true,
        country: Country,
        dismissSheetAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void,
        dismissAfterSuccessAction: @escaping () -> Void,
        dismissAfterErrorAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.notificationCenter = NotificationCenter.default
        self.showImage = showImage
        self.countryToProcess = country
        self.dismissSheetAction = dismissSheetAction
        self.openURLAction = openURLAction
        self.dismissAfterSuccessAction = dismissAfterSuccessAction
        self.dismissAfterErrorAction = dismissAfterErrorAction
        observeAppMoveToForeground()
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

    func allowNotificationsAction() {
        Task {
            let permissionState = await notificationService.permissionState
            DispatchQueue.main.async {
                if permissionState == .authorized {
                    self.subscribeToCountry(notificationsEnabled: true)
                } else if permissionState == .denied {
                    self.displayNotificationSettingsAlert = true
                } else {
                    self.requestNotificationPermission()
                }
            }
        }
    }

    private func requestNotificationPermission() {
        notificationService.requestPermissions { [weak self] granted in
            if granted {
                self?.subscribeToCountry(notificationsEnabled: true)
            }
        }
    }

    func notNowAction() {
        subscribeToCountry(notificationsEnabled: false)
    }

    private func subscribeToCountry(notificationsEnabled: Bool) {
        guard let country = countryToProcess else { return }
        viewState = .loading

        travelService.subscribeToCountry(
            slug: country.slug,
            notificationsEnabled: notificationsEnabled,
            completion: { [weak self] result in
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
        )
    }

    func openPrivacyPolicy() {
        let privacyPolicyURL = URL(string: Constants.API.privacyPolicyUrl.absoluteString)
        if let url = privacyPolicyURL {
            openURLAction(url)
        }
    }

    func handleNotificationAlertAction() {
        if urlOpener.openNotificationSettings() {
            notificationService.toggleHasGivenConsent()
            isPendingPermissionCheck = true
        }
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
            DispatchQueue.main.async {
                if permissionState == .authorized {
                    self.isPendingPermissionCheck = false
                    self.displayNotificationSettingsAlert = false
                    self.subscribeToCountry(notificationsEnabled: true)
                } else {
                    self.isPendingPermissionCheck = false
                    self.displayNotificationSettingsAlert = false
                }
            }
        }
    }
}
