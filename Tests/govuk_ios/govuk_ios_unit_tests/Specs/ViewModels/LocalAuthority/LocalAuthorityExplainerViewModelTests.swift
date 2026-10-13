import Testing

@testable import govuk_ios


@Suite
struct LocalAuthorityExplainerViewModelTests {
    @Test
    func explainerViewPrimaryButtonViewModel_action_trackNavigationEvent() async throws {

        let mockAnalyticsService = MockAnalyticsService()
        let testContainer = DependencyRegistry()
        testContainer.analyticsService = mockAnalyticsService

        DependencyRegistry.$testing.withValue(testContainer) {
            let sut = LocalAuthorityExplainerViewModel(
                navigateToPostcodeEntry: {},
                dismissAction: {}
            )
            sut.primaryButtonViewModel.action()
            let receivedTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
            #expect(receivedTitle == "Continue")
        }
    }
}
