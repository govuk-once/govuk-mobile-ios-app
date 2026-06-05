// swiftlint:disable file_length
import UIKit
import GovKit
import LocalAuthentication

protocol SettingsViewModelInterface: ObservableObject {
    var title: String { get }
    var listContent: [GroupedListSection] { get }
    var scrollToTop: Bool { get set }
    var displayNotificationSettingsAlert: Bool { get set }
    var notificationSettingsAlertTitle: String { get }
    var notificationSettingsAlertBody: String { get }
    var notificationAlertButtonTitle: String { get }
    var notificationsAction: (() -> Void)? { get set }
    var notificationCentreAction: (() -> Void)? { get set }
    var localAuthenticationAction: (() -> Void)? { get set }
    var signoutAction: (() -> Void)? { get set }
    var openAction: ((SettingsViewModelURLParameters) -> Void)? { get set }
    var sarAction: (() -> Void)? { get set }

    func updateNotificationPermissionState()
    func handleNotificationAlertAction()
    func trackScreen(screen: TrackableScreen)
    func updateEmail()
    func loadMessages()
}

struct SettingsViewModelURLParameters {
    let url: URL
    let trackingTitle: String
    let fullScreen: Bool
}

// swiftlint:disable:next type_body_length
class SettingsViewModel: SettingsViewModelInterface {
    private enum MessagesState {
        case notDetermined, loading, error, success(unreadCount: Int), unlinked
    }

    @Published private var messagesState: MessagesState = .unlinked

    let title: String = String(localized: .Settings.pageTitle)
    private let analyticsService: AnalyticsServiceInterface
    private let urlOpener: URLOpener
    private let versionProvider: AppVersionProvider
    private let deviceInformationProvider: DeviceInformationProviderInterface
    private let authenticationService: AuthenticationServiceInterface
    private let localAuthenticationService: LocalAuthenticationServiceInterface
    private let appConfigService: AppConfigServiceInterface
    private let userService: UserService
    private let notificationCentreService: NotificationCentreService

    @Published var scrollToTop: Bool = false
    @Published var displayNotificationSettingsAlert: Bool = false
    @Published private(set) var notificationsPermissionState: NotificationPermissionState
    = .notDetermined
    private let notificationService: NotificationServiceInterface
    private let notificationCenter: NotificationCenter
    var notificationsAction: (() -> Void)?
    var notificationCentreAction: (() -> Void)?
    var localAuthenticationAction: (() -> Void)?
    var notificationAlertButtonTitle: String = String(
        localized: .Settings.notificationAlertPrimaryButtonTitle
    )
    var signoutAction: (() -> Void)?
    var openAction: ((SettingsViewModelURLParameters) -> Void)?
    var sarAction: (() -> Void)?
    @Published var userEmail: String?

    init(analyticsService: AnalyticsServiceInterface,
         urlOpener: URLOpener,
         versionProvider: AppVersionProvider,
         deviceInformationProvider: DeviceInformationProviderInterface,
         authenticationService: AuthenticationServiceInterface,
         notificationService: NotificationServiceInterface,
         notificationCenter: NotificationCenter,
         localAuthenticationService: LocalAuthenticationServiceInterface,
         appConfigService: AppConfigServiceInterface,
         userService: UserService,
         notificationCentreService: NotificationCentreService) {
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.versionProvider = versionProvider
        self.deviceInformationProvider = deviceInformationProvider
        self.authenticationService = authenticationService
        self.notificationService = notificationService
        self.notificationCenter = notificationCenter
        self.localAuthenticationService = localAuthenticationService
        self.appConfigService = appConfigService
        self.userService = userService
        self.notificationCentreService = notificationCentreService
        updateNotificationPermissionState()
        observeAppMoveToForeground()
    }

    private func observeAppMoveToForeground() {
        notificationCenter.addObserver(
            self,
            selector: #selector(updateNotificationPermissionState),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    var notificationSettingsAlertTitle: String {
        return String(localized: (notificationsPermissionState == .authorized ?
                    .Settings.notificationsAlertTitleEnabled :
                        .Settings.notificationsAlertTitleDisabled)
        )
    }

    var notificationSettingsAlertBody: String {
        String(localized: (notificationsPermissionState == .authorized ?
            .Settings.notificationsAlertBodyEnabled :
                .Settings.notificationsAlertBodyDisabled)
        )
    }

    @objc
    func updateNotificationPermissionState() {
        Task {
            let permissionState = await notificationService.permissionState
            DispatchQueue.main.async {
                self.notificationsPermissionState = permissionState
            }
        }
    }

    func handleNotificationAlertAction() {
        guard [.authorized, .denied].contains(notificationsPermissionState),
              urlOpener.openNotificationSettings()
        else { return }
        notificationService.toggleHasGivenConsent()
        trackNavigationEvent(
            notificationAlertButtonTitle,
            external: false
        )
    }

    private var hasAcceptedAnalytics: Bool {
        switch analyticsService.permissionState {
        case .denied, .unknown:
            return false
        case .accepted:
            return true
        }
    }

    var listContent: [GroupedListSection] {
        getGroupedList()
    }

    func updateEmail() {
        Task { @MainActor in
            userEmail = await self.authenticationService.userEmail
        }
    }

    func loadMessages() {
        guard case .notDetermined = messagesState else { return }

        Task {
            messagesState = .loading

            if let linked = userService.isDvlaAccountLinked {
                loadMessageCount(isLinked: linked)
            } else {
                let linked = await userService.fetchAccountLinkStatus(accountType: .dvla)

                switch linked {
                case .success(let linkStatus):
                    loadMessageCount(isLinked: linkStatus.linked)
                case .failure:
                    messagesState = .error
                }
            }
        }
    }

    private func loadMessageCount(isLinked: Bool) {
        guard isLinked else {
            messagesState = .unlinked
            return
        }

        notificationCentreService.fetchNotifications { [weak self] res in
            if case .success(let notifications) = res {
                let unreadCount = notifications.count(where: \.isUnread)
                self?.messagesState = .success(unreadCount: unreadCount)
            } else {
                self?.messagesState = .error
            }
        }
    }

    private func getGroupedList() -> [GroupedListSection] {
        return [
            accountSection,
            messagesSection,
            appConfigService.isFeatureEnabled(key: .dvla) ? linkedAccountsSection : nil,
            appOptionsSection,
            aboutSection,
            policiesSection,
            signOutSection,
        ].compactMap { $0 }
    }

    // MARK: - Account
    private var accountSection: GroupedListSection? {
        guard authenticationService.isSignedIn else { return nil }
        let rowTitle = String(localized: .Settings.manageAccountRowTitle)
        return GroupedListSection(
            heading: nil,
            rows: [
                InformationRow(
                    id: "settings.email.row",
                    title: String(localized: .Settings.accountRowTitle),
                    body: userEmail,
                    imageName: "account_icon",
                    detail: ""),
                LinkRow(
                    id: "settings.account.row",
                    title: rowTitle,
                    action: { [weak self] in
                        self?.openAction?(
                            .init(
                                url: Constants.API.manageAccountURL,
                                trackingTitle: rowTitle,
                                fullScreen: true
                            )
                        )
                        self?.trackNavigationEvent(rowTitle, external: true)
                    }
                )
            ],
            footer: String(localized: .Settings.accountSectionFooter))
    }

    private var messagesSection: GroupedListSection? {
        var state: CountRow.State

        switch messagesState {
        case .notDetermined, .loading:
             state = .loading
        case .success(let unreadCount):
           state = .idle(showIndicator: unreadCount > 0, count: unreadCount)
        case .error, .unlinked:
            return nil
        }
        return GroupedListSection(
            heading: nil, rows: [
                CountRow(
                    id: "settings.messages.row",
                    title: String(localized: .Settings.messagesTitle),
                    state: state,
                    action: { [weak self] in
                        self?.notificationCentreAction?()
                    })
            ], footer: nil)
    }

    // MARK: - Sign out
    private var signOutSection: GroupedListSection? {
        guard authenticationService.isSignedIn else { return nil }
        return GroupedListSection(
            heading: nil,
            rows: [
                DetailRow(
                    id: "settings.signout.row",
                    title: String(localized: .Settings.signOutRowTitle),
                    body: "",
                    accessibilityHint: "",
                    destructive: true,
                    action: { [weak self] in
                        self?.handleSignOutPressed()
                    }
                )
            ],
            footer: nil)
    }

    private func handleSignOutPressed() {
        trackNavigationEvent(
            String.settings.localized(
                String(localized: .Settings.signOutRowTitle)
            ),
            external: false
        )
        signoutAction?()
    }

    // MARK: - App Options
    private var appOptionsSection: GroupedListSection? {
        return GroupedListSection(
            heading: nil,
            rows: appOptionsRows,
            footer: String(localized: .Settings.appUsageFooter)
        )
    }

    private var appOptionsRows: [GroupedListRow] {
        var appOptionRows = [GroupedListRow]()

        if notificationService.isFeatureEnabled {
            let rowTitle = String(localized: .Settings.notificationsTitle)
            let isAuthorized = notificationsPermissionState == .authorized
            let notificationRow = DetailRow(
                id: "settings.notifications.row",
                title: rowTitle,
                body: isAuthorized ? String.common.localized("on") : String.common.localized("off"),
                accessibilityHint: String(localized: .Settings.notificationsAccessibilityHint),
                action: { [weak self] in
                    self?.handleNotificationSettingsPressed(title: rowTitle)
                }
            )
            appOptionRows.append(notificationRow)
        }
        if localAuthenticationService.biometricsPossible {
            let biometricsTitle = switch localAuthenticationService.deviceCapableAuthType {
            case .touchID:
                String(localized: .Settings.touchIdTitle)
            case .faceID:
                String(localized: .Settings.faceIdTitle)
            default:
                ""
            }
            appOptionRows.append(biometricsRow(title: biometricsTitle))
        }
        appOptionRows.append(
            ToggleRow(
                id: "settings.privacy.row",
                title: String(localized: .Settings.appUsageTitle),
                isOn: hasAcceptedAnalytics,
                action: { [weak self] isOn in
                    self?.analyticsService.setAcceptedAnalytics(
                        accepted: isOn
                    )
                }
            )
        )
        return appOptionRows
    }

    private func biometricsRow(title: String) -> GroupedListRow {
        NavigationRow(
            id: "settings.biometrics.row",
            title: title,
            body: nil,
            action: { [weak self] in
                guard let self = self else { return }
                self.trackNavigationEvent(
                    String.settings.localized(title),
                    external: false
                )
                self.localAuthenticationAction?()
            }
        )
    }

    private func handleNotificationSettingsPressed(title: String) {
        if notificationsPermissionState == .notDetermined {
            trackNavigationEvent(
                String.settings.localized(title),
                external: false
            )
            notificationsAction?()
        } else {
            displayNotificationSettingsAlert.toggle()
        }
    }

    // MARK: - About
    private var aboutSection: GroupedListSection {
        GroupedListSection(
            heading: nil,
            rows: [
                InformationRow(
                    id: "settings.version.row",
                    title: String(localized: .Settings.appVersionTitle),
                    body: nil,
                    detail: versionProvider.fullBuildNumber ?? "-"
                ),
                helpAndFeedbackRow
            ],
            footer: nil
        )
    }

    private var linkedAccountsSection: GroupedListSection {
        GroupedListSection(
            heading: nil,
            rows: [accountsRow],
            footer: nil
        )
    }

    private var helpAndFeedbackRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.helpAndFeedbackSettingsTitle)
        return LinkRow(
            id: "settings.helpAndfeedback.row",
            title: rowTitle,
            body: nil,
            action: { [weak self] in
                guard let self else { return }
                let url = self.deviceInformationProvider
                    .helpAndFeedbackURL(versionProvider: self.versionProvider)
                self.openAction?(
                    .init(
                        url: url,
                        trackingTitle: rowTitle,
                        fullScreen: false
                    )
                )
            }
        )
    }

    // MARK: - Policies
    private var policiesSection: GroupedListSection {
        GroupedListSection(
            heading: nil,
            rows: [
                privacyPolicyRow,
                accessibilityStatementRow,
                openSourceLicenceRow,
                termsAndConditionsRow
                // Hide row until such time as it is determined we have info to present the user
                // appConfigService.isFeatureEnabled(key: .profile) ? sarRow : nil
            ].compactMap { $0 },
            footer: nil
        )
    }

    private var privacyPolicyRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.privacyPolicyRowTitle)
        return LinkRow(
            id: "settings.policy.row",
            title: rowTitle,
            body: nil,
            action: { [weak self] in
                self?.openAction?(
                    .init(
                        url: Constants.API.privacyPolicyUrl,
                        trackingTitle: rowTitle,
                        fullScreen: false
                    )
                )
            }
        )
    }

    private var accessibilityStatementRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.accessibilityStatementRowTitle)
        return LinkRow(
            id: "settings.accessibility.row",
            title: rowTitle,
            body: nil,
            action: { [weak self] in
                self?.openAction?(
                    .init(
                        url: Constants.API.accessibilityStatementUrl,
                        trackingTitle: rowTitle,
                        fullScreen: false
                    )
                )
            }
        )
    }

    private var openSourceLicenceRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.openSourceLicenceRowTitle)
        return LinkRow(
            id: "settings.licence.row",
            title: rowTitle,
            body: nil,
            action: { [weak self] in
                if self?.urlOpener.openSettings() == true {
                    self?.trackNavigationEvent(
                        rowTitle,
                        external: true
                    )
                }
            }
        )
    }

    private var accountsRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.linkAccountsTitle)
        return NavigationRow(
            id: "settings.accounts.row",
            title: rowTitle,
            body: nil,
            action: {}
        )
    }

    private var termsAndConditionsRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.termsAndConditionsRowTitle)
        return LinkRow(
            id: "settings.terms.row",
            title: rowTitle,
            body: nil,
            action: { [weak self] in
                guard let self = self,
                      let terms = self.appConfigService.termsAndConditions else {
                    return
                }
                self.openAction?(
                    .init(
                        url: terms.url,
                        trackingTitle: rowTitle,
                        fullScreen: false
                    )
                )
            }
        )
    }

    private var sarRow: GroupedListRow {
        let rowTitle = String(localized: .Settings.sarRowTitle)
        return NavigationRow(
            id: "settings.sar.row",
            title: String(localized: .Settings.sarRowTitle),
            body: nil,
            action: { [weak self] in
                guard let self = self else { return }
                self.trackNavigationEvent(
                    String.settings.localized(rowTitle),
                    external: false
                )
                self.sarAction?()
            }
        )
    }

    // MARK: - Analytics
    private func trackNavigationEvent(_ title: String,
                                      external: Bool) {
        let event = AppEvent.buttonNavigation(
            text: title,
            external: external
        )
        analyticsService.track(event: event)
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}
// swiftlint:enable file_length
