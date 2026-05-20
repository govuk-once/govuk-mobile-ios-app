import Testing
import UIKit

@testable import govuk_ios
@testable import GovKit
@testable import GovKitUI

struct ErrorViewModelTests {

    @Test
    func actionButton_callsAction() {
        var didCallCompletion = false

        let sut = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "Test error title",
            subtitle: "Test error subtitle",
            primaryButtonTitle: "Test button",
            primaryAction: {
                didCallCompletion = true
            },
            trackingName: ""
        )
        sut.primaryButtonViewModel.action()

        #expect(didCallCompletion)
    }

    @Test
    func primaryButtonEmpty_doesNotShowPrimaryButton() {
        let sut = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "Test error title",
            subtitle: "Test error subtitle",
            primaryButtonTitle: "",
            primaryAction: {},
            trackingName: ""
        )
        #expect(sut.showPrimaryButton == false)
    }

    @Test
    func trackScreen_createsCorrectEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ErrorViewModel(
            analyticsService: mockAnalyticsService,
            title: "Test title",
            subtitle: "Test subtitle",
            primaryButtonTitle: "Test button",
            primaryAction: {},
            trackingName: "Chat error"
        )
        let screen = ErrorView(viewModel: sut)
        sut.trackScreen(screen: screen)

        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingName == sut.trackingName)
        #expect(screens.first?.trackingTitle == sut.trackingTitle)
    }
}
