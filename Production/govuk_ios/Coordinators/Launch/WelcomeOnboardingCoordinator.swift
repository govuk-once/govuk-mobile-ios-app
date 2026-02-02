import Foundation
import UIKit
import SwiftUI
import GovKit

class WelcomeOnboardingCoordinator: BaseCoordinator {
    private let navigationController: UINavigationController
    private let authenticationService: AuthenticationServiceInterface
    private let userService: UserServiceInterface
    private let notificationService: NotificationServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private var pendingAuthenticationCoordinator: BaseCoordinator?
    private let deviceInformationProvider: DeviceInformationProviderInterface
    private let versionProvider: AppVersionProvider
    private let completionAction: () -> Void

    private var shouldShowSignInSuccessScreen = false

    private lazy var welcomeOnboardingViewModel: WelcomeOnboardingViewModel = {
        WelcomeOnboardingViewModel(
            completeAction: { [weak self] in
                self?.startAuthentication()
            }
        )
    }()

    init(navigationController: UINavigationController,
         authenticationService: AuthenticationServiceInterface,
         userService: UserServiceInterface,
         notificationService: NotificationServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         deviceInformationProvider: DeviceInformationProviderInterface,
         versionProvider: AppVersionProvider,
         completionAction: @escaping () -> Void) {
        self.navigationController = navigationController
        self.authenticationService = authenticationService
        self.userService = userService
        self.notificationService = notificationService
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.deviceInformationProvider = deviceInformationProvider
        self.versionProvider = versionProvider
        self.completionAction = completionAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        if shouldSkipOnboarding {
            fetchUserState()
        } else {
            setWelcomeOnboardingViewController()
        }
    }

    private func setWelcomeOnboardingViewController(_ animated: Bool = true) {
        let viewController = viewControllerBuilder.welcomeOnboarding(
            viewModel: welcomeOnboardingViewModel
        )
        set(viewController)
    }

    private func startAuthentication() {
        guard pendingAuthenticationCoordinator == nil else { return }
        let authenticationCoordinator = coordinatorBuilder.authentication(
            navigationController: navigationController,
            completionAction: { [weak self] in
                self?.fetchUserState()
            },
            errorAction: { [weak self] error in
                self?.showAuthenticationError(error)
            }
        )
        shouldShowSignInSuccessScreen = true
        start(authenticationCoordinator)
        pendingAuthenticationCoordinator = authenticationCoordinator
    }

    private func showAuthenticationError(_ error: AuthenticationError) {
        pendingAuthenticationCoordinator = nil
        welcomeOnboardingViewModel.showProgressView = false
        guard case .loginFlow(let loginError) = error,
              loginError.reason == .userCancelled else {
            analyticsService.track(error: error)
            setSignInError(error)
            return
        }
    }

    private func setSignInError(_ error: AuthenticationError) {
        let viewController = viewControllerBuilder.signInError(
            error: error,
            feedbackAction: { [weak self, root] error in
                self?.openFeedback(error: error)
                root.popToRootViewController(animated: true)
            },
            retryAction: { [root] in
                root.popToRootViewController(animated: true)
            }
        )
        push(viewController)
    }

    private var shouldSkipOnboarding: Bool {
        authenticationService.isSignedIn
    }

    private func openFeedback(error: AuthenticationError) {
        let url = self.deviceInformationProvider
            .reportProblem(
                versionProvider: self.versionProvider,
                error: error,
            )
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: false
        )
        start(coordinator)
    }

    func fetchUserState() {
        userService.fetchUserState(completion: { [weak self] result in
            switch result {
            case .success(let userState):
                self?.notificationService.register(notificationId: userState.notificationId)
                self?.handleUserStateFetched()
            case .failure(let error):
                self?.startAppUnavailable(error: error.asAppUnavailableError())
            }
        })
    }

    @MainActor
    private func startSignInSuccess() {
        let coordinator = coordinatorBuilder.signInSuccess(
            navigationController: root,
            completion: completionAction
        )
        start(coordinator)
    }

    private func handleUserStateFetched() {
        if shouldShowSignInSuccessScreen {
            startSignInSuccess()
        } else {
            completionAction()
        }
    }

    private func startAppUnavailable(error: AppUnavailableError) {
        let coordinator = coordinatorBuilder.appUnavailable(
            navigationController: root,
            error: error,
            retryAction: { [weak self] completion in
                self?.userService.fetchUserState { result in
                    switch result {
                    case .success(let userState):
                        self?.notificationService.register(notificationId: userState.notificationId)
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            },
            dismissAction: { [weak self] in
                self?.handleUserStateFetched()
            }
        )
        start(coordinator)
    }
}
