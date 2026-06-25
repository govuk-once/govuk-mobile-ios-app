import Foundation
import UIKit
import GovKit

class ChatCoordinator: TabItemCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let deeplinkStore: DeeplinkDataStore
    private let analyticsService: AnalyticsServiceInterface
    private let chatService: ChatServiceInterface
    private let authenticationService: AuthenticationServiceInterface
    private let cancelOnboardingAction: () -> Void
    var isShowingError = false
    private lazy var chatViewController: UIViewController = {
        viewControllerBuilder.chat(
            analyticsService: analyticsService,
            chatService: chatService,
            openURLAction: presentWebView,
            handleError: handleChatError
        )
    }()

    var isEnabled: Bool {
        chatService.isEnabled
    }

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         deepLinkStore: DeeplinkDataStore,
         analyticsService: AnalyticsServiceInterface,
         chatService: ChatServiceInterface,
         authenticationService: AuthenticationServiceInterface,
         cancelOnboardingAction: @escaping () -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.deeplinkStore = deepLinkStore
        self.analyticsService = analyticsService
        self.chatService = chatService
        self.authenticationService = authenticationService
        self.cancelOnboardingAction = cancelOnboardingAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard chatService.chatOnboardingSeen else { return }

        setChatViewController()
        isShowingError = false
    }

    func route(for url: URL) -> ResolvedDeeplinkRoute? {
        return deeplinkStore.route(
            for: url,
            parent: self
        )
    }

    private func presentWebView(url: URL) {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: true
        )
        start(coordinator)
    }

    func didReselectTab() { /* To be implemented */ }
    func didSelectTab(_ selectedTabIndex: Int,
                      previousTabIndex: Int) {
        if selectedTabIndex != previousTabIndex && isShowingError {
            setChatViewController()
            isShowingError = false
        } else {
            showChatOnboardingIfNecessary()
        }
    }

    func showChatOnboardingIfNecessary() {
        guard !chatService.chatOnboardingSeen else { return }
        /*
         The dispatch delay fixes an issue where the chat tab has not
         had time to get added to the view heirarchy before
         attempting to present the onboarding view controller from it.
        */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            present(
                coordinatorBuilder.chatInfoOnboarding(
                    cancelOnboardingAction: cancelOnboardingAction,
                    setChatViewControllerAction: setChatViewController
                )
            )
        }
    }

    private func handleChatError(_ error: ChatError) {
        guard error != .authenticationError else {
            self.authenticationService.signOut(reason: .tokenRefreshFailure)
            return
        }
        setChatError(error)
    }

    private func setChatError(_ error: ChatError) {
        let viewController = viewControllerBuilder.chatError(
            analyticsService: analyticsService,
            error: error,
            action: { [weak self] in
                guard let self else { return }
                switch error {
                case .networkUnavailable:
                    self.setChatViewController()
                case .pageNotFound:
                    self.chatService.clearHistory()
                    self.setChatViewController()
                default:
                    break
                }
            }
        )
        set(viewController, animated: false)
        isShowingError = true
    }

    private func setChatViewController(animated: Bool = false) {
        set(chatViewController, animated: animated)
    }
}
