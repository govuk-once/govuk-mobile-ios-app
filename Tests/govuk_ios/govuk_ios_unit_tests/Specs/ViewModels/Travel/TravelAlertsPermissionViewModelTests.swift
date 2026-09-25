import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelAlertsPermissionViewModelTests {
    let mockAnalyticsService = MockAnalyticsService()

    @Test
    func initialization_setsAllProperties() {
        var completeActionCalled = false
        var dismissActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { completeActionCalled = true },
            dismissAction: { dismissActionCalled = true },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.showImage == true)
        #expect(viewModel.title == "Enable Notifications")
        #expect(viewModel.body == "Get travel alerts")
        #expect(viewModel.primaryButtonTitle == "Enable")
        #expect(viewModel.secondaryButtonTitle == "Not Now")
    }

    @Test
    func primaryButtonViewModel_hasCorrectTitle() {
        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.primaryButtonViewModel.localisedTitle == "Enable")
    }

    @Test
    func secondaryButtonViewModel_hasCorrectTitle() {
        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.secondaryButtonViewModel.localisedTitle == "Not Now")
    }

    @Test
    func primaryButtonAction_tracksEventAndCallsCompleteAction() {
        var completeActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { completeActionCalled = true },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        viewModel.primaryButtonViewModel.action()

        #expect(completeActionCalled == true)
        let events = mockAnalyticsService._trackedEvents
        #expect(events.count == 1)
    }

    @Test
    func secondaryButtonAction_tracksEventAndCallsDismissAction() {
        var dismissActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { dismissActionCalled = true },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        viewModel.secondaryButtonViewModel.action()

        #expect(dismissActionCalled == true)
        let events = mockAnalyticsService._trackedEvents
        #expect(events.count == 1)
    }

    @Test
    func showImage_canBeSetToFalse() {
        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: false,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.showImage == false)
    }

    @Test
    func completeAction_canBeInvoked() {
        var completeActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { completeActionCalled = true },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        viewModel.completeAction()

        #expect(completeActionCalled == true)
    }

    @Test
    func dismissAction_canBeInvoked() {
        var dismissActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { dismissActionCalled = true },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        viewModel.dismissAction()

        #expect(dismissActionCalled == true)
    }

    @Test
    func openPrivacyPolicy_whenActionProvided_callsAction() {
        var privacyActionCalled = false

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { privacyActionCalled = true }
        )

        viewModel.openPrivacyPolicy()

        #expect(privacyActionCalled == true)
    }

    @Test
    func openPrivacyPolicy_whenNoActionProvided_doesNotCrash() {
        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        viewModel.openPrivacyPolicy()
    }

    @Test
    func initialization_setsPrivacyPolicyLinkTitle() {
        let customTitle = "Custom Privacy Link"

        let viewModel = TravelAlertsPermissionViewModel(
            analyticsService: mockAnalyticsService,
            showImage: true,
            title: "Enable Notifications",
            body: "Get travel alerts",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Not Now",
            privacyPolicyLinkTitle: customTitle,
            completeAction: { /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ },
            viewPrivacyAction: { /*Empty For Tests*/ }
        )

        #expect(viewModel.privacyPolicyLinkTitle == customTitle)
    }
}
