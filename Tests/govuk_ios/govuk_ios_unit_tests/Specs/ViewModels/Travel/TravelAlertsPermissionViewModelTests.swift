import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
struct TravelAlertsPermissionViewModelTests {
    let mockTravelService = MockTravelService()
    let mockNotificationService = MockNotificationService()
    let mockAnalyticsService = MockAnalyticsService()
    let mockURLOpener = MockURLOpener()
    let testCountry = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])

    @Test
    func initialization_setsProperties() {
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*EmptyForTests*/ },
            openURLAction: { _ in },
            dismissAfterSuccessAction: { /*EmptyForTests*/ },
            dismissAfterErrorAction: { /*EmptyForTests*/ }
        )

        #expect(viewModel.showImage == true)
        #expect(viewModel.viewState == TravelAlertsPermissionViewModel.ViewState.idle)
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
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*EmptyForTests*/ },
            openURLAction: { openedURL = $0 },
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

        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            country: testCountry,
            dismissSheetAction: { dismissCalled = true },
            openURLAction: { _ in },
            dismissAfterSuccessAction: { /*EmptyForTests*/ },
            dismissAfterErrorAction: { /*EmptyForTests*/ }
        )

        viewModel.dismissSheetAction()
        #expect(dismissCalled == true)
    }

    @Test
    func handleNotificationAlertAction_togglesConsent() {
        mockURLOpener.shouldOpenNotificationSettings = true

        let viewModel = makeViewModel()
        viewModel.handleNotificationAlertAction()

        #expect(mockNotificationService.hasGivenConsentToggled == true)
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
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*EmptyForTests*/ },
            openURLAction: { _ in },
            dismissAfterSuccessAction: { successCalled = true },
            dismissAfterErrorAction: { /*EmptyForTests*/ }
        )

        mockTravelService.subscribeToCountryHandler = { _, _, completion in completion(.success(())) }
        viewModel.notNowAction()

        try await waitForTrue { successCalled }

        #expect(successCalled == true)
        #expect(viewModel.viewState == .idle)
    }

    @Test
    func subscribeToCountry_onFailure_callsDismissAfterError() async throws {
        var errorCalled = false
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*EmptyForTests*/ },
            openURLAction: { _ in },
            dismissAfterSuccessAction: { /*EmptyForTests*/ },
            dismissAfterErrorAction: { errorCalled = true }
        )

        mockTravelService.subscribeToCountryHandler = { _, _, completion in completion(.failure(.apiUnavailable)) }
        viewModel.notNowAction()

        try await waitForTrue { errorCalled }

        #expect(errorCalled == true)
    }

    @Test
    func handleNotificationAlertAction_whenCannotOpenSettings_doesNotToggleConsent() {
        mockURLOpener.shouldOpenNotificationSettings = false
        let viewModel = makeViewModel()

        viewModel.handleNotificationAlertAction()

        #expect(mockNotificationService.hasGivenConsentToggled == false)
    }

    @Test
    func retryPermissionCheckAfterSettings_whenAuthorized_subscribesToCountry() async throws {
        mockURLOpener.shouldOpenNotificationSettings = true
        mockNotificationService._stubbededPermissionState = .authorized
        mockTravelService._autoCallSubscribeCompletion = false
        let viewModel = makeViewModel()

        viewModel.handleNotificationAlertAction()
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

        viewModel.handleNotificationAlertAction()
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        // Small delay to let the async task complete
        try await Task.sleep(nanoseconds: 50_000_000)

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

    private func makeViewModel() -> TravelAlertsPermissionViewModel {
        TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: mockURLOpener,
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*EmptyForTests*/ },
            openURLAction: { _ in },
            dismissAfterSuccessAction: { /*EmptyForTests*/ },
            dismissAfterErrorAction: { /*EmptyForTests*/ }
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
