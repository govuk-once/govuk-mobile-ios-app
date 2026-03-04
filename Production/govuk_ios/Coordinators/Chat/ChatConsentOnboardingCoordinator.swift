import Foundation
import UIKit
import GovKit

class ChatConsentOnboardingCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let chatService: ChatServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let cancelOnboardingAction: () -> Void
    private let completionAction: () -> Void
    private lazy var chatConsentOnboardingViewController: UIViewController = {
        viewControllerBuilder.chatConsentOnboarding(
            analyticsService: analyticsService,
            chatService: chatService,
            cancelOnboardingAction: { [weak self] in
                self?.dismiss(animated: true)
                self?.cancelOnboardingAction()
                self?.finish()
            },
            completionAction: { [weak self] in
                self?.startTermsOnboarding()
            }
        )
    }()

    private lazy var chatTermsOnboardingViewController: UIViewController = {
        viewControllerBuilder.chatTermsOnboarding(
            analyticsService: analyticsService,
            chatService: chatService,
            cancelOnboardingAction: { [weak self] in
                self?.dismiss(animated: true)
                self?.cancelOnboardingAction()
                self?.finish()
            },
            completionAction: { [weak self] in
                self?.completionAction()
                self?.dismiss(animated: true)
                self?.finish()
            },
            openURLAction: presentWebView
        )
    }()

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         coordinatorBuilder: CoordinatorBuilder,
         analyticsService: AnalyticsServiceInterface,
         chatService: ChatServiceInterface,
         cancelOnboardingAction: @escaping () -> Void,
         completionAction: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
        self.chatService = chatService
        self.cancelOnboardingAction = cancelOnboardingAction
        self.completionAction = completionAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        push(chatConsentOnboardingViewController)
    }

    private func startTermsOnboarding() {
        push(chatTermsOnboardingViewController)
    }

    private func presentWebView(url: URL) {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: true
        )
        start(coordinator)
    }
}
