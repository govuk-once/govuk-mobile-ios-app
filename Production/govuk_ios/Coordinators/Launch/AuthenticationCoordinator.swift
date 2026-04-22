import Foundation
import GovKit
import UIKit
import Authentication

class AuthenticationCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let authenticationService: AuthenticationServiceInterface
    private let localAuthenticationService: LocalAuthenticationServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let topicsService: TopicsServiceInterface
    private let chatService: ChatServiceInterface
    private let termsAndConditonsService: TermsAndConditionsServiceInterface
    private let completionAction: () -> Void
    private let errorAction: (AuthenticationError) -> Void

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         authenticationService: AuthenticationServiceInterface,
         localAuthenticationService: LocalAuthenticationServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         topicsService: TopicsServiceInterface,
         chatService: ChatServiceInterface,
         termsAndConditionsService: TermsAndConditionsServiceInterface,
         completionAction: @escaping () -> Void,
         errorAction: @escaping (AuthenticationError) -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.authenticationService = authenticationService
        self.localAuthenticationService = localAuthenticationService
        self.analyticsService = analyticsService
        self.topicsService = topicsService
        self.chatService = chatService
        self.termsAndConditonsService = termsAndConditionsService
        self.completionAction = completionAction
        self.errorAction = errorAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        Task {
            await authenticate()
        }
    }

    private func authenticate() async {
        guard let window = root.view.window else {
            return
        }

        let result = await authenticationService.authenticate(window: window)
        switch result {
        case .success(let response):
            if shouldEncryptRefreshToken {
                authenticationService.encryptRefreshToken()
            }
            handleAnalyticsConsent(response: response)
            handleOnboarding(response: response)
            termsAndConditonsService.saveAcceptanceDate()
            completionAction()
        case .failure(let error):
            DispatchQueue.main.async {
                self.errorAction(error)
            }
        }
    }

    private func handleAnalyticsConsent(response: AuthenticationServiceResponse) {
        if !response.returningUser {
            analyticsService.resetConsent()
        } else {
            analyticsService.setExistingConsent()
        }
    }

    private func handleOnboarding(response: AuthenticationServiceResponse) {
        guard !response.returningUser else { return }
        topicsService.resetOnboarding()
        localAuthenticationService.clear()
        chatService.clear()
    }

    private var shouldEncryptRefreshToken: Bool {
        guard localAuthenticationService.authenticationOnboardingFlowSeen else {
            return false
        }

        return switch localAuthenticationService.availableAuthType {
        case .faceID:
            !localAuthenticationService.faceIdSkipped
        case .touchID:
            localAuthenticationService.touchIdEnabled
        default:
            false
        }
    }
}
