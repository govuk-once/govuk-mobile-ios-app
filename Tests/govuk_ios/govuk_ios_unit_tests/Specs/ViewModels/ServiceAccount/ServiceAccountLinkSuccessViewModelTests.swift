import Testing

@testable import govuk_ios

@Suite
class ServiceAccountLinkSuccessViewModelTests {

    @Test
    func init_dvla_createsCorrectTitle() {
        let sut = ServiceAccountLinkSuccessViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {}
        )
        #expect(sut.title == "Driver and vehicles account added")
    }

    @Test
    func primaryButtonAction_callsCompletionAction() {
        var completionWasCalled = false
        let sut = ServiceAccountLinkSuccessViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {
                completionWasCalled = true
            }
        )
        sut.primaryButtonViewModel.action()
        #expect(completionWasCalled == true)
    }

    @Test
    func primaryButtonAction_tracksNavigationEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ServiceAccountLinkSuccessViewModel(
            analyticsService: mockAnalyticsService,
            accountType: .dvla,
            completionAction: {}
        )
        sut.primaryButtonViewModel.action()
        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Button")
        #expect(event.params?["text"] as? String == "Continue")
        #expect(event.params?["section"] as? String == "account link success")
    }
}

