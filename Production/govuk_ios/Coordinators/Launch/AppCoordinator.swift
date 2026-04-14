import UIKit
import Foundation
import GovKit

class AppCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let inactivityService: InactivityServiceInterface
    private let authenticationService: AuthenticationServiceInterface
    private let localAuthenticationService: LocalAuthenticationServiceInterface
    private let notificationService: NotificationServiceInterface
    private let userService: UserServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let tokenProvider: TokenProviding
    private var initialLaunch: Bool = true
    private lazy var tabCoordinator: BaseCoordinator = {
        let coordinator = coordinatorBuilder.tab(
            navigationController: root
        )
        return coordinator
    }()
    private var pendingDeeplink: URL?
    private var privacyPresenter: PrivacyPresenting?

    init(coordinatorBuilder: CoordinatorBuilder,
         inactivityService: InactivityServiceInterface,
         authenticationService: AuthenticationServiceInterface,
         localAuthenticationService: LocalAuthenticationServiceInterface,
         notificationService: NotificationServiceInterface,
         userService: UserServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         tokenProvider: TokenProviding,
         privacyPresenter: PrivacyPresenting? = nil,
         navigationController: UINavigationController) {
        self.coordinatorBuilder = coordinatorBuilder
        self.inactivityService = inactivityService
        self.authenticationService = authenticationService
        self.localAuthenticationService = localAuthenticationService
        self.notificationService = notificationService
        self.userService = userService
        self.analyticsService = analyticsService
        self.privacyPresenter = privacyPresenter
        self.tokenProvider = tokenProvider
        super.init(navigationController: navigationController)
        configureObservers()
    }

    private func configureObservers() {
        authenticationService.didSignOutAction = { [weak self] reason in
            if reason == .reauthFailure {
                // Any presented modals need to be dismissed or they
                // will be on top of the sign in flow
                self?.root.dismiss(animated: false)
                self?.hidePrivacyScreen()
                return
            }
            self?.notificationService.unregisterNotificationId()
            self?.startPeriAuthCoordinator()
        }

        notificationService.addConsentChangedListener { [weak self] consentGiven in
            self?.handleNotificationConsentChange(consentGiven: consentGiven)
        }
    }

    private func handleNotificationConsentChange(consentGiven: Bool) {
        guard authenticationService.isSignedIn else { return }
        if let notificationId = userService.notificationId {
            notificationService.register(notificationId: notificationId)
            let consentStatus: ConsentStatus = consentGiven ? .accepted : .denied
            userService.setNotificationsConsent(consentStatus)
        }
    }

    override func start(url: URL?) {
        startInactivityMonitoring()
        pendingDeeplink = url ?? pendingDeeplink
        if initialLaunch {
            startPreAuthCoordinator()
        } else {
            reLaunch()
        }
    }

    private func startInactivityMonitoring() {
        inactivityService.startMonitoring(
            inactivityHandler: { [weak self] in
                guard self?.authenticationService.isSignedIn == true else { return }
                self?.authenticationService.signOut(reason: .userSignout)
                self?.showPrivacyScreen()
            },
            alertHandler: { [weak self] in
                guard self?.authenticationService.isSignedIn == true else { return }
                self?.privacyPresenter?.showPrivacyAlert()
            }
        )
    }

    private func startPreAuthCoordinator() {
        let coordinator = coordinatorBuilder.preAuth(
            navigationController: root,
            completion: { [weak self] in
                self?.initialLaunch = false
                self?.startPeriAuthCoordinator()
            }
        )
        start(coordinator)
    }

    private func startPeriAuthCoordinator() {
        let coordinator = coordinatorBuilder.periAuth(
            navigationController: root,
            completion: { [weak self] in
                self?.hidePrivacyScreen()
                self?.startPostAuthCoordinator()
            }
        )
        start(coordinator)
    }

    private func startPostAuthCoordinator() {
        let coordinator = coordinatorBuilder.postAuth(
            navigationController: root,
            completion: { [weak self] in
                self?.startSession()
            }
        )
        start(coordinator)
    }

    private func reLaunch() {
        let coordinator = coordinatorBuilder.relaunch(
            navigationController: root,
            completion: { [weak self] in
                self?.handlePendingDeeplink()
            }
        )
        start(coordinator)
    }

    private func handlePendingDeeplink() {
        if let url = pendingDeeplink {
            tabCoordinator.start(url: url)
            pendingDeeplink = nil
        }
    }

    private func startTabs() {
        checkForNilAccessToken()
        start(tabCoordinator, url: pendingDeeplink)
        pendingDeeplink = nil
    }

    private func checkForNilAccessToken() {
        if tokenProvider.accessToken == nil {
            analyticsService.track(
                error: AccessTokenError.noAccessTokenPresent
            )
        }
    }

    private func startSession() {
        startTabs()
        inactivityService.resetTimers()
    }
}

extension AppCoordinator {
    private func showPrivacyScreen() {
        privacyPresenter?.hidePrivacyAlert()
        if shouldShowPrivacyScreen {
            privacyPresenter?.showPrivacyScreen()
        }
    }

    private func hidePrivacyScreen() {
        privacyPresenter?.hidePrivacyScreen()
    }

    private var shouldShowPrivacyScreen: Bool {
        (localAuthenticationService.availableAuthType == .faceID ||
        localAuthenticationService.touchIdEnabled)
    }
}
