import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
struct NotificationsRationaleViewModelTests {
    let mockTravelService = MockTravelService()
    let mockNotificationService = MockNotificationService()
    let mockAnalyticsService = MockAnalyticsService()
    let mockURLOpener = MockURLOpener()
    let testCountry = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])

    @Test
    func initialization_setsProperties() {
        let viewModel = makeViewModel()

        #expect(viewModel.showImage == true)
        #expect(viewModel.viewState == NotificationsRationaleViewModel.ViewState.idle)
        #expect(viewModel.displayNotificationSettingsAlert == false)
    }

    @Test
    func primaryButtonViewModel_triggersAllowNotificationsAction() {
        let viewModel = makeViewModel()
        viewModel.primaryButtonViewModel.action()
        // Action executes asynchronously, test framework waits
    }

    @Test
    func secondaryButtonViewModel_triggersNotNowAction() {
        let viewModel = makeViewModel()
        viewModel.secondaryButtonViewModel.action()
        // Action executes asynchronously, test framework waits
    }

    @Test
    func notNowAction_subscribesWithNotificationsDisabled() {
        mockTravelService.subscribeToCountryHandler = { slug, enabled, completion in
            #expect(slug == "france")
            #expect(enabled == false)
            completion(.success(()))
        }

        let viewModel = makeViewModel()
        viewModel.notNowAction()
    }

    @Test
    func openPrivacyPolicy_opensURL() {
        var openedURL: URL?
        let viewModel = NotificationsRationaleViewModel(
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            saveAction: { _, completion in completion(.success(())) },
            declineBehaviour: .saveDisabled,
            dismissSheetAction: { /*EmptyForTests*/ },
            openExternalURLAction: { openedURL = $0 },
            dismissAfterSuccessAction: { /*EmptyForTests*/ },
            dismissAfterErrorAction: { /*EmptyForTests*/ }
        )

        viewModel.openPrivacyPolicy()

        #expect(openedURL != nil)
    }

    @Test
    func viewState_startsAsIdle() {
        let viewModel = makeViewModel()
        #expect(viewModel.viewState == .idle)
    }

    @Test
    func displayNotificationSettingsAlert_startsAsFalse() {
        let viewModel = makeViewModel()
        #expect(viewModel.displayNotificationSettingsAlert == false)
    }

    @Test
    func dismissSheetAction_canBeInvoked() {
        var dismissCalled = false

        let viewModel = makeViewModel(dismissSheetAction: { dismissCalled = true })

        viewModel.dismissSheetAction()
        #expect(dismissCalled == true)
    }

    @Test
    func handleNotificationAlertAction_opensNotificationSettings_returnsNoError() {
        mockURLOpener.shouldOpenNotificationSettings = true

        let viewModel = makeViewModel()
        viewModel.onSettingsAlertContinueAction()

    }

    @Test
    func allowNotificationsAction_whenAuthorized_subscribesWithNotificationsEnabled() async throws {
        mockNotificationService._stubbededPermissionState = .authorized
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel()

        viewModel.allowNotificationsAction()

        try await waitForTrue { viewModel.viewState == .loading }

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._recievedSubscribeBool == true)
    }

    @Test
    func allowNotificationsAction_whenDenied_displaysSettingsAlert() async throws {
        mockNotificationService._stubbededPermissionState = .denied
        let viewModel = makeViewModel()

        viewModel.allowNotificationsAction()

        try await waitForTrue { viewModel.displayNotificationSettingsAlert == true }

        #expect(viewModel.displayNotificationSettingsAlert == true)
    }

    @Test
    func allowNotificationsAction_whenNotDetermined_requestsPermissions() async throws {
        mockNotificationService._stubbededPermissionState = .notDetermined
        let viewModel = makeViewModel()

        viewModel.allowNotificationsAction()

        try await waitForTrue { mockNotificationService._receivedRequestPermissionsCompletion != nil }

        #expect(mockNotificationService._receivedRequestPermissionsCompletion != nil)
    }

    @Test
    func allowNotificationsAction_whenNotDetermined_andPermissionDenied_subscribesWithNotificationsDisabled() async throws {
        mockNotificationService._stubbededPermissionState = .notDetermined
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel()

        viewModel.allowNotificationsAction()
        try await waitForTrue { mockNotificationService._receivedRequestPermissionsCompletion != nil }

        // Simulate OS "Don't Allow"
        mockNotificationService._receivedRequestPermissionsCompletion?(false)

        try await waitForTrue { viewModel.viewState == .loading }

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._recievedSubscribeBool == false)
    }

    @Test
    func notNowAction_setsLoadingStateDuringSubscription() {
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel()

        viewModel.notNowAction()

        if case .loading = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .loading during subscription")
        }
    }

    @Test
    func subscribeToCountry_onSuccess_resetsToIdleAndCallsDismiss() async throws {
        var successCalled = false
        let viewModel = makeViewModel(dismissAfterSuccessAction: { successCalled = true })

        mockTravelService.subscribeToCountryHandler = { _, _, completion in completion(.success(())) }
        viewModel.notNowAction()

        try await waitForTrue { successCalled }

        #expect(successCalled == true)
        #expect(viewModel.viewState == .idle)
    }

    @Test
    func subscribeToCountry_onFailure_callsDismissAfterError() async throws {
        var errorCalled = false
        let viewModel = makeViewModel(dismissAfterErrorAction: { errorCalled = true })

        mockTravelService.subscribeToCountryHandler = { _, _, completion in completion(.failure(.apiUnavailable)) }
        viewModel.notNowAction()

        try await waitForTrue { errorCalled }

        #expect(errorCalled == true)
    }

    @Test
    func handleNotificationAlertAction_whenCannotOpenSettings_doesNotToggleConsent() {
        mockURLOpener.shouldOpenNotificationSettings = false
        let viewModel = makeViewModel()

        viewModel.onSettingsAlertContinueAction()

        #expect(mockNotificationService.hasGivenConsentToggled == false)
    }

    @Test
    func retryPermissionCheckAfterSettings_whenAuthorized_subscribesToCountry() async throws {
        mockURLOpener.shouldOpenNotificationSettings = true
        mockNotificationService._stubbededPermissionState = .authorized
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel()

        viewModel.onSettingsAlertContinueAction()
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        try await waitForTrue { viewModel.viewState == .loading }

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(viewModel.displayNotificationSettingsAlert == false)
    }

    @Test
    func retryPermissionCheckAfterSettings_whenNotAuthorized_doesNotSubscribe() async throws {
        mockURLOpener.shouldOpenNotificationSettings = true
        mockNotificationService._stubbededPermissionState = .denied
        let viewModel = makeViewModel()

        viewModel.onSettingsAlertContinueAction()
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        try await Task.sleep(for: .seconds(1))

        #expect(mockTravelService._subscribeToGroupsCalled == false)
        #expect(viewModel.displayNotificationSettingsAlert == false)
    }

    @Test
    func notificationSettingsStrings_returnsLocalisedStrings() {
        let viewModel = makeViewModel()

        let title = viewModel.notificationSettingsAlertTitle
        #expect(!title.isEmpty)
        let body = viewModel.notificationSettingsAlertBody
        #expect(!body.isEmpty)
        let buttonTitle = viewModel.notificationAlertButtonTitle
        #expect(!buttonTitle.isEmpty)
    }

    @Test
    func notificationSettingsStrings_remainsConsistentAcrossInstances() {
        let viewModel1 = makeViewModel()
        let viewModel2 = makeViewModel()

        let title1 = viewModel1.notificationSettingsAlertTitle
        let title2 = viewModel2.notificationSettingsAlertTitle

        #expect(title1 == title2)

        let body1 = viewModel1.notificationSettingsAlertBody
        let body2 = viewModel2.notificationSettingsAlertBody

        #expect(body1 == body2)


        let buttonTitle1 = viewModel1.notificationAlertButtonTitle
        let buttonTitle2 = viewModel2.notificationAlertButtonTitle

        #expect(buttonTitle1 == buttonTitle2)
    }

    @Test
    func viewDidAppear_tracksAnalyticsEvent() {
        let viewModel = makeViewModel()
        viewModel.viewDidAppear()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents[0].name == "notifications_rationale_view")
        #expect(mockAnalyticsService._trackedEvents[0].params?["origin"] as? String == "FOLLOW")
    }

    @Test
    func viewDidAppear_withEditOrigin_tracksAnalyticsEventWithEditOrigin() {
        let viewModel = makeViewModel(origin: .EDIT)
        viewModel.viewDidAppear()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents[0].name == "notifications_rationale_view")
        #expect(mockAnalyticsService._trackedEvents[0].params?["origin"] as? String == "EDIT")
    }

    @Test
    func allowNotificationsAction_tracksAnalyticsEvent() async throws {
        mockNotificationService._stubbededPermissionState = .authorized
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel()

        viewModel.allowNotificationsAction()

        try await waitForTrue { mockAnalyticsService._trackedEvents.count >= 1 }

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)

        // allowNotificationsAction tracks a button navigation event
        let buttonNavEvent = events.first(where: {
            $0.name == "Navigation" && $0.params?["type"] as? String == "Button"
        })
        #expect(buttonNavEvent != nil)
        #expect(buttonNavEvent?.params?["text"] as? String == viewModel.primaryButtonTitle)
        #expect(buttonNavEvent?.params?["external"] as? Bool == false)
        #expect(buttonNavEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func notNowAction_tracksButtonNavigationAnalyticsEvent() {
        let viewModel = makeViewModel()
        viewModel.notNowAction()

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)

        // notNowAction tracks a button navigation event
        let buttonNavEvent = events.first(where: {
            $0.name == "Navigation" && $0.params?["type"] as? String == "Button"
        })
        #expect(buttonNavEvent != nil)
        #expect(buttonNavEvent?.params?["text"] as? String == viewModel.secondaryButtonTitle)
        #expect(buttonNavEvent?.params?["external"] as? Bool == false)
        #expect(buttonNavEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func onSettingsAlertContinueAction_tracksAnalyticsEvent() {
        mockURLOpener.shouldOpenNotificationSettings = true
        let viewModel = makeViewModel()

        viewModel.onSettingsAlertContinueAction()

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)

        let settingsEvent = events.first(where: {
            $0.name == "notifications_rationale_settings_continue"
        })
        #expect(settingsEvent != nil)
        #expect(settingsEvent?.params?["origin"] as? String == "FOLLOW")
    }

    @Test
    func onSettingsAlertCancelAction_tracksAnalyticsEvent() {
        let viewModel = makeViewModel()
        viewModel.onSettingsAlertCancelAction()

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)

        let settingsEvent = events.first(where: {
            $0.name == "notifications_rationale_settings_cancel"
        })
        #expect(settingsEvent != nil)
        #expect(settingsEvent?.params?["origin"] as? String == "FOLLOW")
    }

    @Test
    func viewDidAppear_withEditOrigin_tracksOriginInAnalytics() {
        let viewModel = makeViewModel(origin: .EDIT)

        viewModel.viewDidAppear()

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)

        // viewDidAppear tracks notification rationale view event with origin
        let viewEvent = events.first(where: {
            $0.name == "notifications_rationale_view"
        })
        #expect(viewEvent != nil)
        #expect(viewEvent?.params?["origin"] as? String == "EDIT")
    }

    @Test
    func enterBackground_afterAgreeingWithPermissionDenied_acceptsConsent() async throws {
        let notificationCenter = NotificationCenter()
        mockNotificationService._stubbededPermissionState = .denied
        let viewModel = makeViewModel(notificationCenter: notificationCenter)

        viewModel.allowNotificationsAction()
        try await waitForTrue { viewModel.displayNotificationSettingsAlert }
        withExtendedLifetime(viewModel) {
            notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        }

        #expect(mockNotificationService._acceptConsentCalled == true)
    }

    @Test
    func enterBackground_afterAgreeingThenCancelling_doesNotAcceptConsent() async throws {
        let notificationCenter = NotificationCenter()
        mockNotificationService._stubbededPermissionState = .denied
        let viewModel = makeViewModel(notificationCenter: notificationCenter)

        viewModel.allowNotificationsAction()
        try await waitForTrue { viewModel.displayNotificationSettingsAlert }
        viewModel.onSettingsAlertCancelAction()
        withExtendedLifetime(viewModel) {
            notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        }

        #expect(mockNotificationService._acceptConsentCalled == false)
    }

    @Test
    func enterBackground_withoutAgreeing_doesNotAcceptConsent() {
        let notificationCenter = NotificationCenter()
        let viewModel = makeViewModel(notificationCenter: notificationCenter)

        withExtendedLifetime(viewModel) {
            notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        }

        #expect(mockNotificationService._acceptConsentCalled == false)
    }

    // MARK: - T6: Fire view event once

    @Test
    func viewDidAppear_calledTwice_tracksOnce() {
        let viewModel = makeViewModel()
        viewModel.viewDidAppear()
        viewModel.viewDidAppear()

        let viewEvents = mockAnalyticsService._trackedEvents.filter {
            $0.name == "notifications_rationale_view"
        }
        #expect(viewEvents.count == 1)
    }

    // MARK: - T8: Privacy notice external=false

    @Test
    func openPrivacyPolicy_tracksButtonNavigation() {
        let viewModel = makeViewModel()
        viewModel.openPrivacyPolicy()

        let navEvent = mockAnalyticsService._trackedEvents.first(where: {
            $0.name == "Navigation" && $0.params?["type"] as? String == "Button"
        })
        #expect(navEvent != nil)
        #expect(navEvent?.params?["external"] as? Bool == false)
        #expect(navEvent?.params?["text"] as? String == viewModel.privacyPolicyLinkTitle)
        #expect(navEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func enterForeground_afterLeavingApp_whenAuthorized_subscribesToCountry() async throws {
        let notificationCenter = NotificationCenter()
        mockNotificationService._stubbededPermissionState = .denied
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel(notificationCenter: notificationCenter)

        viewModel.allowNotificationsAction()
        try await waitForTrue { viewModel.displayNotificationSettingsAlert }
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        mockNotificationService._stubbededPermissionState = .authorized
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        try await waitForTrue { viewModel.viewState == .loading }

        #expect(mockTravelService._subscribeToGroupsCalled == true)
    }

    private func makeViewModel(
        saveAction: NotificationsRationaleSaveAction? = nil,
        declineBehaviour: NotificationsRationaleDeclineBehaviour = .saveDisabled,
        dismissSheetAction: @escaping () -> Void = { },
        openExternalURLAction: @escaping (URL) -> Void = { _ in },
        dismissAfterSuccessAction: @escaping () -> Void = { },
        dismissAfterErrorAction: @escaping () -> Void = { },
        origin: NotificationsRationaleOrigin = .FOLLOW,
        notificationCenter: NotificationCenter = .default
    ) -> NotificationsRationaleViewModel {
        let finalSaveAction = saveAction ?? { enabled, completion in
            self.mockTravelService.subscribeToCountry(
                slug: "france",
                notificationsEnabled: enabled,
                completion: completion
            )
        }

        return NotificationsRationaleViewModel(
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            notificationCenter: notificationCenter,
            showImage: true,
            saveAction: finalSaveAction,
            declineBehaviour: declineBehaviour,
            dismissSheetAction: dismissSheetAction,
            openExternalURLAction: openExternalURLAction,
            dismissAfterSuccessAction: dismissAfterSuccessAction,
            dismissAfterErrorAction: dismissAfterErrorAction,
            origin: origin
        )
    }

    private func waitForTrue(
        timeout: TimeInterval = 1.0,
        condition: () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            await Task.yield()
        }
        if !condition() {
            throw TestError.timeout
        }
    }

    private enum TestError: Error {
        case timeout
    }
}
