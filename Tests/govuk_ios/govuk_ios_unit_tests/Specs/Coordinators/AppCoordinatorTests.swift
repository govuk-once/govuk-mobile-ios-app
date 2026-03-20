import UIKit
import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct AppCoordinatorTests {
    @Test
    func start_firstLaunch_startsLaunchCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedPreAuthCoordinator = mockCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        subject.start()

        #expect(mockCoordinatorBuilder._receivedPreAuthNavigationController == mockNavigationController)
        #expect(mockCoordinator._startCalled)
        #expect(mockAuthenticationService.didSignOutAction != nil)
    }

    @Test
    func start_secondLaunch_startsTabCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockPreAuthCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        let mockTabCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        let mockRelaunchCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedPreAuthCoordinator = mockPreAuthCoordinator
        mockCoordinatorBuilder._stubbedTabCoordinator = mockTabCoordinator
        mockCoordinatorBuilder._stubbedRelaunchCoordinator = mockRelaunchCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        //First launch
        subject.start()

        #expect(mockPreAuthCoordinator._startCalled)
        #expect(!mockRelaunchCoordinator._startCalled)

        mockCoordinatorBuilder._receivedPreAuthCompletion?()
        mockCoordinatorBuilder._receivedPeriAuthCompletion?()
        mockCoordinatorBuilder._receivedPostAuthCompletion?()

        #expect(mockTabCoordinator._startCalled)

        //Reset values for second launch
        mockPreAuthCoordinator._startCalled = false
        mockTabCoordinator._startCalled = false

        //Second launch
        subject.start()

        #expect(!mockPreAuthCoordinator._startCalled)
        #expect(mockRelaunchCoordinator._startCalled)
    }

    @Test
    func relaunchCompletion_withTabCoordinator_withURL_startsTabCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockPreAuthCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        let mockTabCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        let mockRelaunchCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedPreAuthCoordinator = mockPreAuthCoordinator
        mockCoordinatorBuilder._stubbedTabCoordinator = mockTabCoordinator
        mockCoordinatorBuilder._stubbedRelaunchCoordinator = mockRelaunchCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        //First launch
        subject.start()

        #expect(mockPreAuthCoordinator._startCalled)
        #expect(!mockRelaunchCoordinator._startCalled)

        mockCoordinatorBuilder._receivedPreAuthCompletion?()
        mockCoordinatorBuilder._receivedPeriAuthCompletion?()
        mockCoordinatorBuilder._receivedPostAuthCompletion?()

        #expect(mockTabCoordinator._startCalled)

        //Reset values for second launch
        mockPreAuthCoordinator._startCalled = false
        mockTabCoordinator._startCalled = false

        //Second launch
        let expectedURL = URL(string: "https://www.google.com")
        subject.start(url: expectedURL)

        #expect(mockRelaunchCoordinator._startCalled)

        mockCoordinatorBuilder._receivedRelaunchCompletion?()

        #expect(mockTabCoordinator._startCalled)
        #expect(mockTabCoordinator._receivedStartURL == expectedURL)
    }

    @Test
    func relaunchCompletion_withTabCoordinator_withNo_doesntStartTabCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockPreAuthCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        let mockTabCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        let mockRelaunchCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedPreAuthCoordinator = mockPreAuthCoordinator
        mockCoordinatorBuilder._stubbedTabCoordinator = mockTabCoordinator
        mockCoordinatorBuilder._stubbedRelaunchCoordinator = mockRelaunchCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        //First launch
        subject.start()

        #expect(mockPreAuthCoordinator._startCalled)
        #expect(!mockRelaunchCoordinator._startCalled)

        mockCoordinatorBuilder._receivedPreAuthCompletion?()
        mockCoordinatorBuilder._receivedPeriAuthCompletion?()
        mockCoordinatorBuilder._receivedPostAuthCompletion?()

        #expect(mockTabCoordinator._startCalled)

        //Reset values for second launch
        mockPreAuthCoordinator._startCalled = false
        mockTabCoordinator._startCalled = false

        //Second launch
        subject.start(url: nil)

        #expect(mockRelaunchCoordinator._startCalled)

        mockCoordinatorBuilder._receivedRelaunchCompletion?()

        #expect(!mockTabCoordinator._startCalled)
    }

    @Test
    func successfulSignout_startsLoginCoordinator() throws {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockLaunchCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedLaunchCoordinator = mockLaunchCoordinator

        let tabCoordinator = TabCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            navigationController: mockNavigationController,
            analyticsService: MockAnalyticsService()
        )

        let periAuthCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )

        mockCoordinatorBuilder._stubbedTabCoordinator = tabCoordinator
        mockCoordinatorBuilder._stubbedPeriAuthCoordinator = periAuthCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        //First launch
        subject.start()

        mockCoordinatorBuilder._receivedPreAuthCompletion?()
        mockCoordinatorBuilder._receivedPeriAuthCompletion?()
        mockCoordinatorBuilder._receivedPostAuthCompletion?()

        tabCoordinator.finish()
        #expect(periAuthCoordinator._startCalled)
    }

    @Test
    func start_withMissingAccessToken_tracksError() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let analyticsService = MockAnalyticsService()
        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: analyticsService,
            tokenProvider: mockAuthenticationService,
            navigationController: mockNavigationController
        )
        mockAuthenticationService._stubbedAccessToken = nil

        subject.start(url: nil)

        mockCoordinatorBuilder._receivedPreAuthCompletion?()
        mockCoordinatorBuilder._receivedPeriAuthCompletion?()
        mockCoordinatorBuilder._receivedPostAuthCompletion?()

        let expectedError = AccessTokenError.noAccessTokenPresent
        #expect((analyticsService._trackErrorReceivedErrors.first as? AccessTokenError) == expectedError)
    }

    @Test
    func start_withAccessToken_doesNotTrackError() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let analyticsService = MockAnalyticsService()
        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: analyticsService,
            tokenProvider: mockAuthenticationService,
            navigationController: mockNavigationController
        )
        mockAuthenticationService._stubbedAccessToken = "test_token"

        subject.start(url: nil)

        mockCoordinatorBuilder._receivedPreAuthCompletion?()
        mockCoordinatorBuilder._receivedPeriAuthCompletion?()
        mockCoordinatorBuilder._receivedPostAuthCompletion?()

        #expect(analyticsService._trackErrorReceivedErrors.count == 0)
    }


    @Test
    func inactivity_startsPeriAuth() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()

        let mockPeriAuthCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedPeriAuthCoordinator = mockPeriAuthCoordinator
        mockAuthenticationService._stubbedIsSignedIn = true

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        subject.start(url: nil)
        mockInactivityService._receivedStartMonitoringInactivityHandler?()

        #expect(mockPeriAuthCoordinator._startCalled)
    }

    @Test(arguments: [
        SignoutReason.tokenRefreshFailure,
        SignoutReason.userSignout,
    ])
    func start_didSignOutAction_userSignout_startsPeriAuthCoordinator(reason: SignoutReason) {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedPreAuthCoordinator = mockCoordinator

        let mockPeriAuthCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedPeriAuthCoordinator = mockPeriAuthCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            navigationController: mockNavigationController
        )

        subject.start(url: nil)

        mockAuthenticationService.didSignOutAction?(reason)

        #expect(mockPeriAuthCoordinator._startCalled)
    }

    @Test
    func start_didSignOutAction_reauthFailed_startsPeriAuthCoordinator() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        let mockCoordinator = MockBaseCoordinator(
            navigationController: mockNavigationController
        )
        mockCoordinatorBuilder._stubbedPreAuthCoordinator = mockCoordinator

        let mockPeriAuthCoordinator = MockBaseCoordinator()
        let mockPrivacyService = MockPrivacyService()
        mockCoordinatorBuilder._stubbedPeriAuthCoordinator = mockPeriAuthCoordinator

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: mockPrivacyService,
            navigationController: mockNavigationController
        )

        subject.start(url: nil)

        mockAuthenticationService.didSignOutAction?(.reauthFailure)

        #expect(!mockPeriAuthCoordinator._startCalled)
        #expect(mockPrivacyService._didHidePrivacyScreen)
    }

    @Test
    func inactivityWithBiometrics_presentsPrivacyScreen() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        let mockNotificationService = MockNotificationService()
        mockLocalAuthenticationService._stubbedAvailableAuthType = .faceID
        let mockPrivacyService = MockPrivacyService()

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: mockPrivacyService,
            navigationController: mockNavigationController
        )
        mockAuthenticationService._stubbedIsSignedIn = true
        subject.start()
        mockInactivityService._receivedStartMonitoringInactivityHandler?()

        #expect(mockPrivacyService._didHidePrivacyAlert)
        #expect(mockPrivacyService._didShowPrivacyScreen)
    }

    @Test
    func inactivityWithoutBiometrics_doesntPresentsPrivacyScreen() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        mockLocalAuthenticationService._stubbedAvailableAuthType = .none
        mockLocalAuthenticationService._stubbedTouchIdEnabled = false
        let mockPrivacyService = MockPrivacyService()
        let mockNotificationService = MockNotificationService()

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: mockNotificationService,
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: mockPrivacyService,
            navigationController: mockNavigationController
        )
        mockAuthenticationService._stubbedIsSignedIn = true
        subject.start()
        mockInactivityService._receivedStartMonitoringInactivityHandler?()

        #expect(mockPrivacyService._didHidePrivacyAlert)
        #expect(!mockPrivacyService._didShowPrivacyScreen)
    }

    @Test
    func inactivityWithBiometrics_presentsPrivacyWarningScreen() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        mockLocalAuthenticationService._stubbedAvailableAuthType = .faceID
        let mockPrivacyService = MockPrivacyService()

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: mockPrivacyService,
            navigationController: mockNavigationController
        )
        mockAuthenticationService._stubbedIsSignedIn = true
        subject.start()
        mockInactivityService._receivedStartMonitoringAlertHandler?()

        #expect(mockPrivacyService._didShowPrivacyAlert)
    }

    @Test
    func inactivityWithoutBiometrics_presentsPrivacyWarningScreen() {
        let mockAuthenticationService = MockAuthenticationService()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNavigationController = UINavigationController()
        let mockInactivityService = MockInactivityService()
        let mockLocalAuthenticationService = MockLocalAuthenticationService()
        mockLocalAuthenticationService._stubbedAvailableAuthType = .none
        mockLocalAuthenticationService._stubbedTouchIdEnabled = false
        let mockPrivacyService = MockPrivacyService()

        let subject = AppCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            inactivityService: mockInactivityService,
            authenticationService: mockAuthenticationService,
            localAuthenticationService: mockLocalAuthenticationService,
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: mockPrivacyService,
            navigationController: mockNavigationController
        )
        mockAuthenticationService._stubbedIsSignedIn = true
        subject.start()
        mockInactivityService._receivedStartMonitoringAlertHandler?()

        #expect(mockPrivacyService._didShowPrivacyAlert)
    }

    @Test
    func notificationConsentChanged_isSignedIn_callsUserServiceSetConsent() {
        let mockUserService = MockUserService()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedIsSignedIn = true
        mockUserService._stubbedNotificationId = "test_notification_id"
        let mockNotificationService = MockNotificationService()
        let subject = AppCoordinator(
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            inactivityService: MockInactivityService(),
            authenticationService: mockAuthenticationService,
            localAuthenticationService: MockLocalAuthenticationService(),
            notificationService: mockNotificationService,
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: MockPrivacyService(),
            navigationController: MockNavigationController())
        subject.start()
        mockNotificationService._receivedOnConsentChangedAction?(true)
        #expect(mockUserService._receivedNotificationConsent == .accepted)
        #expect(mockUserService.notificationId == "test_notification_id")
    }

    @Test
    func notificationConsentAccepted_isSignedIn_callsNotificationServiceRegister() {
        let mockUserService = MockUserService()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedIsSignedIn = true
        mockUserService._stubbedNotificationId = "test_notification_id"
        let mockNotificationService = MockNotificationService()
        let subject = AppCoordinator(
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            inactivityService: MockInactivityService(),
            authenticationService: mockAuthenticationService,
            localAuthenticationService: MockLocalAuthenticationService(),
            notificationService: mockNotificationService,
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: MockPrivacyService(),
            navigationController: MockNavigationController())
        subject.start()
        mockNotificationService._receivedOnConsentChangedAction?(true)
        #expect(mockNotificationService._stubbedNotificationId == "test_notification_id")
        #expect(mockUserService.notificationId == "test_notification_id")
    }

    @Test
    func notificationConsentAccepted_isNotSignedIn_doesNotCallNotificationServiceRegister() {
        let mockUserService = MockUserService()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedIsSignedIn = false
        mockUserService._stubbedNotificationId = "test_notification_id"
        let mockNotificationService = MockNotificationService()
        let subject = AppCoordinator(
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            inactivityService: MockInactivityService(),
            authenticationService: mockAuthenticationService,
            localAuthenticationService: MockLocalAuthenticationService(),
            notificationService: mockNotificationService,
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
            tokenProvider: MockAuthenticationService(),
            privacyPresenter: MockPrivacyService(),
            navigationController: MockNavigationController())
        subject.start()
        mockNotificationService._receivedOnConsentChangedAction?(true)
        #expect(mockNotificationService._stubbedNotificationId == nil)
        #expect(mockUserService.notificationId == "test_notification_id")
    }
}
