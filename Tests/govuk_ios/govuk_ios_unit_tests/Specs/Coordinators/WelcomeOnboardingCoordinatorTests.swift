import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
class WelcomeOnboardingCoordinatorTests {

    // MARK: start signed in
    @Test
    func start_signedIn_userStateRequestSuccess_finishesCoordination() async {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchUserStateResult = .success(UserState.arrange)
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        mockAuthenticationService._stubbedIsSignedIn = true
        let completion = await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingCoordinator(
                navigationController: mockNavigationController,
                authenticationService: mockAuthenticationService,
                userService: mockUserService,
                notificationService: mockNotificationService,
                coordinatorBuilder: mockCoordinatorBuilder,
                viewControllerBuilder: MockViewControllerBuilder(),
                analyticsService: MockAnalyticsService(),
                deviceInformationProvider: MockDeviceInformationProvider(),
                versionProvider: MockAppVersionProvider(),
                completionAction: { continuation.resume(returning: true) }
            )
            sut.start(url: nil)
        }

        #expect(completion)
        #expect(mockNavigationController._setViewControllers?.count == .none)
    }

    @Test
    func start_signedIn_userStateRequestSuccess_setsNotificationExternalId() async {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchUserStateResult = .success(UserState.arrange)
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        mockAuthenticationService._stubbedIsSignedIn = true
        let completion = await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingCoordinator(
                navigationController: mockNavigationController,
                authenticationService: mockAuthenticationService,
                userService: mockUserService,
                notificationService: mockNotificationService,
                coordinatorBuilder: mockCoordinatorBuilder,
                viewControllerBuilder: MockViewControllerBuilder(),
                analyticsService: MockAnalyticsService(),
                deviceInformationProvider: MockDeviceInformationProvider(),
                versionProvider: MockAppVersionProvider(),
                completionAction: { continuation.resume(returning: true) }
            )
            sut.start(url: nil)
        }

        #expect(completion)
        #expect(mockNotificationService._stubbedNotificationId == "test_id")
    }

    @Test
    func start_signedIn_userStateRequestFailure_startsAppUnavailableCoordinator() async {
        let mockAuthenticationService = MockAuthenticationService()
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchUserStateResult = .failure(UserStateError.apiUnavailable)
        let mockAppUnavailableCoordinator = MockBaseCoordinator()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        mockCoordinatorBuilder._stubbedAppUnavailableCoordinator = mockAppUnavailableCoordinator
        mockAuthenticationService._stubbedIsSignedIn = true
        await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingCoordinator(
                navigationController: MockNavigationController(),
                authenticationService: mockAuthenticationService,
                userService: mockUserService,
                notificationService: MockNotificationService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                viewControllerBuilder: MockViewControllerBuilder(),
                analyticsService: MockAnalyticsService(),
                deviceInformationProvider: MockDeviceInformationProvider(),
                versionProvider: MockAppVersionProvider(),
                completionAction: { }
            )
            mockUserService._fetchUserStateCompletionBlock = {
                continuation.resume()
            }
            sut.start(url: nil)
        }

        #expect(mockAppUnavailableCoordinator._startCalled == true)
    }

    // MARK: start not signed in

    @Test
    func start_notSignedIn_setsOnboarding() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        mockAuthenticationService._stubbedIsSignedIn = false
        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: mockAuthenticationService,
            userService: mockUserService,
            notificationService: mockNotificationService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: MockViewControllerBuilder(),
            analyticsService: MockAnalyticsService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )
        sut.start(url: nil)

        #expect(mockNavigationController._setViewControllers?.count == .some(1))
    }

    @Test
    func authenticationSuccess_userStateRequestSuccess_startsSignInSuccessCoordinator() async {
        let mockUserService = MockUserService()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockSignInSuccessCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSignInSuccessCoordinator = mockSignInSuccessCoordinator
        mockUserService._stubbedFetchUserStateResult = .success(UserState.arrange)

        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let completion = await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingCoordinator(
                navigationController: MockNavigationController(),
                authenticationService: MockAuthenticationService(),
                userService: mockUserService,
                notificationService: MockNotificationService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                deviceInformationProvider: MockDeviceInformationProvider(),
                versionProvider: MockAppVersionProvider(),
                completionAction: { }
            )
            sut.start(url: nil)
            mockCoordinatorBuilder._signInSuccessCallAction = {
                continuation.resume(returning: true)
            }

            mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
            mockCoordinatorBuilder._receivedAuthenticationCompletion?()
        }

        #expect(completion)
        #expect(mockSignInSuccessCoordinator._startCalled)
    }

    @Test
    func authenticationSuccess_userStateRequestSuccess_setNotificationExternalId() async {
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockSignInSuccessCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSignInSuccessCoordinator = mockSignInSuccessCoordinator
        mockUserService._stubbedFetchUserStateResult = .success(UserState.arrange)

        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let completion = await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingCoordinator(
                navigationController: MockNavigationController(),
                authenticationService: MockAuthenticationService(),
                userService: mockUserService,
                notificationService: mockNotificationService,
                coordinatorBuilder: mockCoordinatorBuilder,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                deviceInformationProvider: MockDeviceInformationProvider(),
                versionProvider: MockAppVersionProvider(),
                completionAction: { }
            )
            sut.start(url: nil)
            mockCoordinatorBuilder._signInSuccessCallAction = {
                continuation.resume(returning: true)
            }

            mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
            mockCoordinatorBuilder._receivedAuthenticationCompletion?()
        }

        #expect(completion)
        #expect(mockNotificationService._stubbedNotificationId == "test_id")
    }

    @Test
    func authenticationSuccess_userStateRequestFailure_startsAppUnavailableCoordinator() async {
        let mockUserService = MockUserService()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockAppUnavailableCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedAppUnavailableCoordinator = mockAppUnavailableCoordinator
        mockUserService._stubbedFetchUserStateResult = .failure(UserStateError.apiUnavailable)

        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingCoordinator(
                navigationController: MockNavigationController(),
                authenticationService: MockAuthenticationService(),
                userService: mockUserService,
                notificationService: MockNotificationService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                deviceInformationProvider: MockDeviceInformationProvider(),
                versionProvider: MockAppVersionProvider(),
                completionAction: { }
            )
            mockUserService._fetchUserStateCompletionBlock = {
                continuation.resume()
            }
            sut.start(url: nil)

            mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
            mockCoordinatorBuilder._receivedAuthenticationCompletion?()
        }

        #expect(mockAppUnavailableCoordinator._startCalled == true)
    }

    @Test
    func appUnavailable_retrySuccess_returnsExpectedResult() async {
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        mockUserService._stubbedFetchUserStateResult = .failure(UserStateError.apiUnavailable)

        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: MockAuthenticationService(),
            userService: mockUserService,
            notificationService: MockNotificationService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )
        sut.start(url: nil)
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
        mockCoordinatorBuilder._receivedAuthenticationCompletion?()
        mockUserService._stubbedFetchUserStateResult = .success(UserState.arrange)

        let completion = await withCheckedContinuation { continuation in
            mockCoordinatorBuilder._receivedAppUnavailableRetryAction? { wasSuccessful in
                continuation.resume(returning: wasSuccessful)
            }
        }

        #expect(completion)
    }

    @Test
    func authenticationError_startsSignInErrorCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let stubbedSignInErrorViewController = UIViewController()
        mockViewControllerBuilder._stubbedSignInErrorViewController = stubbedSignInErrorViewController

        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: mockAuthenticationService,
            userService: mockUserService,
            notificationService: mockNotificationService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )

        sut.start(url: nil)

        mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
        mockCoordinatorBuilder._receivedAuthenticationErrorAction?(.loginFlow(.init(reason: .authorizationAccessDenied)))

        #expect(mockNavigationController._pushedViewController == stubbedSignInErrorViewController)
    }

    @Test
    func authenticationError_tracksError() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let stubbedSignInErrorViewController = UIViewController()
        mockViewControllerBuilder._stubbedSignInErrorViewController = stubbedSignInErrorViewController

        let mockAnalyticsService = MockAnalyticsService()
        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: mockAuthenticationService,
            userService: mockUserService,
            notificationService: mockNotificationService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: mockAnalyticsService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )

        sut.start(url: nil)

        let expectedError = AuthenticationError.loginFlow(.init(reason: .authorizationAccessDenied))
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
        mockCoordinatorBuilder._receivedAuthenticationErrorAction?(expectedError)

        #expect((mockAnalyticsService._trackErrorReceivedErrors.first as? AuthenticationError) == expectedError)
    }

    @Test
    func userCancelledError_does_not_start_SignInErrorCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let stubbedSignInErrorViewController = UIViewController()
        mockViewControllerBuilder._stubbedSignInErrorViewController = stubbedSignInErrorViewController

        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: mockAuthenticationService,
            userService: mockUserService,
            notificationService: mockNotificationService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )

        sut.start(url: nil)

        mockCoordinatorBuilder._receivedAuthenticationErrorAction?(.loginFlow(.init(reason: .userCancelled)))

        #expect(mockNavigationController._setViewControllers?.first == stubbedWelcomeOnboardingViewController)
    }

    @Test
    func signInErrorCompletion_setsWelcomOnboarding() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let stubbedSignInErrorViewController = UIViewController()
        mockViewControllerBuilder._stubbedSignInErrorViewController = stubbedSignInErrorViewController

        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: mockAuthenticationService,
            userService: mockUserService,
            notificationService: mockNotificationService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )

        sut.start(url: nil)

        mockCoordinatorBuilder._receivedAuthenticationErrorAction?(.loginFlow(.init(reason: .authorizationAccessDenied)))
        mockViewControllerBuilder._receivedSignInErrorRetryAction?()

        #expect(mockNavigationController._setViewControllers?.first == stubbedWelcomeOnboardingViewController)
    }

    @Test
    func signInErrorCompletion_feedbackAction_setsWelcomOnboarding() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockUserService = MockUserService()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator

        let stubbedWelcomeOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewController = stubbedWelcomeOnboardingViewController

        let stubbedSignInErrorViewController = UIViewController()
        mockViewControllerBuilder._stubbedSignInErrorViewController = stubbedSignInErrorViewController

        let sut = WelcomeOnboardingCoordinator(
            navigationController: mockNavigationController,
            authenticationService: mockAuthenticationService,
            userService: mockUserService,
            notificationService: mockNotificationService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completionAction: { }
        )

        sut.start(url: nil)

        let expectedError = AuthenticationError.unknown(TestError.anyError)
        mockViewControllerBuilder._stubbedWelcomeOnboardingViewModel?.completeAction()
        mockCoordinatorBuilder._receivedAuthenticationErrorAction?(expectedError)
        mockViewControllerBuilder._receivedSignInErrorFeedbackAction?(expectedError)

        #expect(mockNavigationController._setViewControllers?.first == stubbedWelcomeOnboardingViewController)
        #expect(mockSafariCoordinator._startCalled)
    }
}
