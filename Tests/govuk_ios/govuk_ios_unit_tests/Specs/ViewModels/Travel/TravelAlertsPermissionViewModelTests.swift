import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelAlertsPermissionViewModelTests {
    let mockAnalyticsService = MockAnalyticsService()
    let mockTravelService = MockTravelService()
    let mockNotificationService = MockNotificationService()
    let testCountry = Country(
        slug: "france",
        name: "France",
        synonyms: [],
        updatedAt: nil,
        id: "1"
    )

    @Test
    func initialization_setsAllProperties() {
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: MockURLOpener(),
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ },
            dismissAfterSuccessAction: { /*Empty For Tests*/ },
            dismissAfterErrorAction: { /*Empty For Tests*/ }
        )
        NotificationCenter.default.removeObserver(viewModel)

        #expect(viewModel.showImage == true)
        #expect(viewModel.title == "Enable Notifications")
        #expect(viewModel.body == "Get travel alerts")
        #expect(viewModel.primaryButtonTitle == "Enable")
        #expect(viewModel.secondaryButtonTitle == "Not Now")
        #expect(viewModel.viewState == .idle)
    }

    @Test
    func primaryButtonViewModel_hasCorrectTitle() {
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: MockURLOpener(),
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ },
            dismissAfterSuccessAction: { /*Empty For Tests*/ },
            dismissAfterErrorAction: { /*Empty For Tests*/ }
        )
        NotificationCenter.default.removeObserver(viewModel)

        #expect(viewModel.primaryButtonViewModel.localisedTitle == "Enable")
    }

    @Test
    func secondaryButtonViewModel_hasCorrectTitle() {
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            urlOpener: MockURLOpener(),
            showImage: true,
            country: testCountry,
            dismissSheetAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ },
            dismissAfterSuccessAction: { /*Empty For Tests*/ },
            dismissAfterErrorAction: { /*Empty For Tests*/ }
        )
        NotificationCenter.default.removeObserver(viewModel)

        #expect(viewModel.secondaryButtonViewModel.localisedTitle == "Not Now")
    }

    @Test
    func showImage_canBeSetToFalse() {
        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            showImage: false,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            country: testCountry,
            dismissSheetAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ },
            dismissAfterSuccessAction: { /*Empty For Tests*/ },
            dismissAfterErrorAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.showImage == false)
    }

    @Test
    func initialization_setsPrivacyPolicyLinkTitle() {
        let customTitle = "Custom Privacy Link"

        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            privacyPolicyLinkTitle: customTitle,
            country: testCountry,
            dismissSheetAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ },
            dismissAfterSuccessAction: { /*Empty For Tests*/ },
            dismissAfterErrorAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.privacyPolicyLinkTitle == customTitle)
    }

    @Test
    func openPrivacyPolicy_callsOpenURLAction() {
        var openURLActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            travelService: mockTravelService,
            notificationService: mockNotificationService,
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            country: testCountry,
            dismissSheetAction: { /*Empty For Tests*/ },
            openURLAction: { _ in openURLActionCalled = true },
            dismissAfterSuccessAction: { /*Empty For Tests*/ },
            dismissAfterErrorAction: { /*Empty For Tests*/ }
        )

        viewModel.openPrivacyPolicy()

        #expect(openURLActionCalled == true)
    }
}
