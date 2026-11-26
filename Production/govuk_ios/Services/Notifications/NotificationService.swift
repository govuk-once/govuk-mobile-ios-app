import Foundation
import UIKit
import UserNotifications

import OneSignalFramework

protocol NotificationServiceInterface {
    func appDidFinishLaunching(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func requestPermissions(completion: ((Bool) -> Void)?)
    func addClickListener(onClickAction: @escaping (URL) -> Void)
    func acceptConsent()
    func rejectConsent()
    func toggleHasGivenConsent()
    var shouldRequestPermission: Bool { get async }
    var permissionState: NotificationPermissionState { get async }
    var isFeatureEnabled: Bool { get }
    func fetchConsentAlignment() async -> NotificationConsentResult
    func register(pushId: String)
    func oneSignalStateError(pushId: String) -> OneSignalStateError?
    func unregisterPushId()
    var hasGivenConsent: Bool { get }
    func addConsentChangedListener(action: @escaping (Bool) -> Void)
}

extension NotificationServiceInterface {
    var needsTravelAlertsPermissionFlow: Bool {
        get async {
            let isConsented = hasGivenConsent
            let isAuthorized = await permissionState == .authorized
            return !(isConsented && isAuthorized)
        }
    }
}

class NotificationService: NSObject,
                           NotificationServiceInterface,
                           OSNotificationClickListener {
    private var environmentService: AppEnvironmentServiceInterface
    private let notificationCenter: UserNotificationCenterInterface
    private let configService: AppConfigServiceInterface
    private let userDefaultsService: UserDefaultsServiceInterface
    private let oneSignalServiceClient: OneSignalServiceClient.Type
    private let notificationCentreService: () -> NotificationCentreServiceInterface
    private var onConsentChangedAction: ((Bool) -> Void)?
    var onClickAction: ((URL) -> Void)?

    init(environmentService: AppEnvironmentServiceInterface,
         notificationCenter: UserNotificationCenterInterface,
         configService: AppConfigServiceInterface,
         userDefaultsService: UserDefaultsServiceInterface,
         oneSignalServiceClient: OneSignalServiceClient.Type,
         notificationCentreService: @escaping () -> NotificationCentreServiceInterface) {
        self.environmentService = environmentService
        self.notificationCenter = notificationCenter
        self.configService = configService
        self.userDefaultsService = userDefaultsService
        self.oneSignalServiceClient = oneSignalServiceClient
        self.notificationCentreService = notificationCentreService
    }

    func appDidFinishLaunching(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        oneSignalServiceClient.setConsentRequired(true)
        oneSignalServiceClient.initialize(
            appId: environmentService.oneSignalAppId,
            launchOptions: launchOptions
        )
    }

    var permissionState: NotificationPermissionState {
        get async {
            let localStatus = await notificationCenter.authorizationStatus
            switch localStatus {
            case .authorized:
                return .authorized
            case .denied:
                return .denied
            case .notDetermined, .ephemeral, .provisional:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        }
    }

    var shouldRequestPermission: Bool {
        get async {
            let switches = (
                isFeatureEnabled,
                await permissionState == .notDetermined
            )
            return switches.0 && switches.1
        }
    }

    var isFeatureEnabled: Bool {
        configService.isFeatureEnabled(key: .notifications)
    }

    var hasGivenConsent: Bool {
        userDefaultsService.bool(forKey: .notificationsConsentGranted)
    }

    func acceptConsent() {
        updateConsent(given: true)
    }

    func rejectConsent() {
        updateConsent(given: false)
    }

    func toggleHasGivenConsent() {
        var permission = hasGivenConsent
        permission.toggle()
        updateConsent(given: permission)
    }

    private func updateConsent(given: Bool) {
        let previousConsent = userDefaultsService.bool(forKey: .notificationsConsentGranted)
        userDefaultsService.set(bool: given, forKey: .notificationsConsentGranted)
        oneSignalServiceClient.setConsentGiven(given)
        if previousConsent != given {
            onConsentChangedAction?(given)
        }
    }

    // Ask iOS first, then give OneSignal consent based on the answer.
    //
    // We used to give consent first, because OneSignal's own requestPermission won't run without
    // it. That started the SDK while the prompt was still on screen, so it created the user and
    // push subscription marked "asked, not answered". If the user then tapped Allow, that stale
    // update could reach OneSignal after the "subscribed" one and leave them stuck as "Never
    // Subscribed" (OneSignal SDK-4874, fixed in SDK 5.5.5; this removes the window entirely).
    // If they tapped Don't Allow, OneSignal was left with a record for someone who had refused.
    //
    // Calling iOS directly is supported: OneSignal intercepts requestAuthorization and records
    // the answer, and reads the permission from iOS when it starts.
    func requestPermissions(completion: ((Bool) -> Void)?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            // The same options OneSignal's own prompt asks for.
            let granted = (try? await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )) ?? false
            updateConsent(given: granted)
            if granted {
                // Giving consent only starts the SDK if it was waiting for consent at launch.
                // If consent was on at launch and has been turned off since, turning it back on
                // doesn't restart anything, and the SDK wouldn't send the new permission until
                // the app next comes to the foreground. iOS has already answered, so this shows
                // no dialog; it just runs OneSignal's after-prompt update straight away.
                oneSignalServiceClient.Notifications.requestPermission(
                    nil,
                    fallbackToSettings: false
                )
            }
            completion?(granted)
        }
    }

    func addClickListener(onClickAction: @escaping (URL) -> Void) {
        oneSignalServiceClient.Notifications.addClickListener(self)
        self.onClickAction = onClickAction
    }

    func addConsentChangedListener(action: @escaping (Bool) -> Void) {
        self.onConsentChangedAction = action
    }

    func onClick(event: OSNotificationClickEvent) {
        handleAdditionalData(event.notification.additionalData)
    }

    func handleAdditionalData(_ additionalData: [AnyHashable: Any]?) {
        guard let additionalData,
              let deeplinkStr = additionalData["deeplink"] as? String,
              !deeplinkStr.isEmpty,
              let components = URLComponents(string: deeplinkStr),
              let url = components.url else {
            return
        }

        onClickAction?(url)

        if let notificationId = components.queryItems?.first(
            where: { $0.name == "notificationID" }
        )?.value {
            notificationCentreService().markRead(with: notificationId)
        }
    }

    func fetchConsentAlignment() async -> NotificationConsentResult {
        let isSubscribed = await permissionState == .authorized
        switch (hasGivenConsent, isSubscribed) {
        case (true, false):
            return .misaligned(.consentGrantedNotificationsOff)
        case (false, true):
            return .misaligned(.consentNotGrantedNotificationsOn)
        default:
            return .aligned
        }
    }

    func register(pushId: String) {
        guard hasGivenConsent else { return }
        oneSignalServiceClient.login(pushId)
    }

    // Compares what the OneSignal SDK saved on this device with the signed-in user, and returns
    // an error to report if they don't match.
    //
    // Call it on app start for a returning user, before register. Logging in again can repair
    // the state, which would hide what the previous session left behind. Don't call it after a
    // fresh sign-in: that starts logged out of OneSignal, so a mismatch there is expected.
    func oneSignalStateError(pushId: String) -> OneSignalStateError? {
        // Only users who have consented should be linked in OneSignal.
        guard hasGivenConsent else { return nil }
        let state = oneSignalServiceClient.deviceState
        let error = OneSignalStateError(
            externalIdSet: !(state.externalId ?? "").isEmpty,
            externalIdMatches: state.externalId == pushId,
            onesignalIdSet: !(state.onesignalId ?? "").isEmpty,
            pushSubscriptionIdSet: !(state.pushSubscriptionId ?? "").isEmpty,
            pushOptedIn: state.pushOptedIn
        )
        return error.isConsistent ? nil : error
    }

    func unregisterPushId() {
        oneSignalServiceClient.logout()
    }
}

enum NotificationConsentResult: Equatable {
    case aligned
    case misaligned(NotificationConsentMisalignment)
}

enum NotificationConsentMisalignment: Equatable {
    case consentNotGrantedNotificationsOn
    case consentGrantedNotificationsOff
}
