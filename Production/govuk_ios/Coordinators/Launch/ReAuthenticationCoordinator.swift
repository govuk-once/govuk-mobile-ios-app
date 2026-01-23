import Foundation
import UIKit
import GovKit

class ReAuthenticationCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let authenticationService: AuthenticationServiceInterface
    private let localAuthenticationService: LocalAuthenticationServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let notificationService: NotificationServiceInterface
    private let completionAction: () -> Void

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         authenticationService: AuthenticationServiceInterface,
         localAuthenticationService: LocalAuthenticationServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         notificationService: NotificationServiceInterface,
         completionAction: @escaping () -> Void) {
        self.authenticationService = authenticationService
        self.localAuthenticationService = localAuthenticationService
        self.completionAction = completionAction
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
        self.userService = userService
        self.notificationService = notificationService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard authenticationService.shouldAttemptTokenRefresh
        else { return handleReauthFailure() }
        Task {
            await reauthenticate()
        }
    }

    private func reauthenticate() async {
        let policy = localAuthenticationService.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics
        )
        guard policy.canEvaluate else {
            if authenticationService.isSignedIn {
                await sendRefreshRequest()
            } else {
                completionAction()
            }
            return
        }
        guard !localAuthenticationService.biometricsHaveChanged else {
            handleReauthFailure()
            return
        }
        guard localAuthenticationService.availableAuthType == .faceID ||
                localAuthenticationService.touchIdEnabled else {
            handleReauthFailure()
            return
        }
        guard !localAuthenticationService.faceIdSkipped else {
            handleReauthFailure()
            return
        }

        await sendRefreshRequest()
    }

    private func sendRefreshRequest() async {
        let refreshRequestResult = await authenticationService.tokenRefreshRequest()

        switch refreshRequestResult {
        case .success:
            analyticsService.setExistingConsent()
            fetchUserInfo()
        case .failure:
            handleReauthFailure()
        }
    }

    private func handleReauthFailure() {
        authenticationService.signOut(reason: .reauthFailure)
        let coordinator = coordinatorBuilder.welcomeOnboarding(
            navigationController: root,
            completionAction: completionAction
        )
        start(coordinator)
    }

    private func fetchUserInfo() {
        userService.fetchUserInfo(completion: { [weak self] result in
            switch result {
            case .success(let userInfo):
                self?.notificationService.register(notificationId: userInfo.userId)
                self?.completionAction()
            case .failure(let error):
                print(error)
                // show app unavailable screen
            }
        })
    }
}
