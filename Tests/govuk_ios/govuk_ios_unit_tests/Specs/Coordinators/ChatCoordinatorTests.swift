import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ChatCoordinatorTests {
    init() {
        UIView.setAnimationsEnabled(false)
    }

    @Test
    func start_setsChatViewController() throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }

    @Test
    func start_onboardingNotSeen_setsChatViewController() throws {
        let mockChatService = MockChatService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.start()
        #expect(navigationController.viewControllers.isEmpty)
    }

    @Test
    func openChatURL_showsSafariWebView() throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator

        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedChatViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatController = expectedChatViewController

        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.start(url: nil)
        mockViewControllerBuilder._receivedChatOpenURLAction?(URL(string: "https://example.com")!)
        #expect(mockSafariCoordinator._startCalled)
    }

    @Test
    func networkUnavailable_showsInfoView() throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedErrorController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.start(url: nil)
        mockViewControllerBuilder._receivedChatHandleError?(ChatError.networkUnavailable)
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }

    @Test
    func handleNetworkUnavailableError_showsChatView() throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedChatViewController = UIViewController()
        let expectedInfoViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatController = expectedChatViewController
        mockViewControllerBuilder._stubbedErrorController = expectedInfoViewController
        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.start(url: nil)
        mockViewControllerBuilder._receivedChatHandleError?(ChatError.networkUnavailable)
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedInfoViewController)
        mockViewControllerBuilder._receivedErrorViewModel?.primaryButtonViewModel.action()
        let nextViewController = navigationController.viewControllers.first
        #expect(nextViewController == expectedChatViewController)
    }

    @Test
    func handlePageNotFoundError_clearsHistory_and_showsChatView() throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        mockChatService._clearHistoryCalled = false
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedChatViewController = UIViewController()
        let expectedInfoViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatController = expectedChatViewController
        mockViewControllerBuilder._stubbedErrorController = expectedInfoViewController
        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.start(url: nil)
        mockViewControllerBuilder._receivedChatHandleError?(ChatError.pageNotFound)
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedInfoViewController)
        mockViewControllerBuilder._receivedErrorViewModel?.primaryButtonViewModel.action()
        let nextViewController = navigationController.viewControllers.first
        #expect(nextViewController == expectedChatViewController)
        #expect(mockChatService._clearHistoryCalled)
    }

    @Test
    func chatViewController_handleError_secondAttempt_authenticationError_showsInfoView() throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockPeriAuthCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedPeriAuthCoordinator = mockPeriAuthCoordinator

        let expectedInfoViewController = UIViewController()
        mockViewControllerBuilder._stubbedErrorController = expectedInfoViewController

        let mockAuthenticationService = MockAuthenticationService()

        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: mockAuthenticationService,
            cancelOnboardingAction: { }
        )

        mockChatService._stubbedRetryAction = {
            mockChatService._stubbedIsRetryAction = true
        }
        mockChatService._stubbedIsRetryAction = true
        sut.start(url: nil)
        mockViewControllerBuilder._receivedChatHandleError?(ChatError.authenticationError)
        let firstViewController = navigationController.viewControllers.first
        #expect(mockAuthenticationService._tokenRefreshRequestCalled == false)
        #expect(firstViewController == expectedInfoViewController)
    }


    @Test
    func didSelectTab_isShowingError_setsChatViewController() {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = true
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )
        sut.isShowingError = true

        sut.didSelectTab(1, previousTabIndex: 0)
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
        #expect(!sut.isShowingError)
    }

    @Test
    @MainActor
    func didSelectTab_onboardingNotSeen_showsOnboarding() async throws {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = false
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatInfoOnboardingController = expectedViewController
        let navigationController = MockNavigationController()
        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        sut.didSelectTab(1, previousTabIndex: 0)
        try await Task.sleep(for: .seconds(1))
        #expect(navigationController._presentedViewController != nil)
        #expect(!sut.isShowingError)
    }

    @Test
    @MainActor
    func routeForURL() async {
        let mockChatService = MockChatService()
        mockChatService.chatOnboardingSeen = false
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatInfoOnboardingController = expectedViewController
        let navigationController = UINavigationController()

        let sut = ChatCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deepLinkStore: DeeplinkDataStore.chat(
                coordinatorBuilder: mockCoordinatorBuilder,
                root: navigationController
            ),
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )

        let route = sut.route(for: URL(string: "govuk://gov.uk/chat")!)
        #expect(route!.route.pattern == "/chat")
    }

}
