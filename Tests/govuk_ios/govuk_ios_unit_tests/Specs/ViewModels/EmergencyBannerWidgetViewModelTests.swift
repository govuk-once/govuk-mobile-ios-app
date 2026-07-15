import Foundation
import Testing

@testable import GovKit

@testable import govuk_ios
struct EmergencyBannerWidgetViewModelTests {

    @Test
    func open_callsOpenURLAction_withBannerURL() {
        let bannerURL = Constants.API.govukBaseUrl
        var expectedURL: URL?
        let sut = EmergencyBannerWidgetViewModel(
            banner: .init(
                id: "emergency_two",
                title: "National Emergency",
                body: "This is a Level 1 emergency",
                link: .init(title: "More information",
                            url: bannerURL),
                type: "national-emergency",
                allowsDismissal: true
            ),
            analyticsService: MockAnalyticsService(),
            sortPriority: 1,
            openURLAction: { url in
                expectedURL = url
            },
            didSelectAction: { },
            dismissAction: { }
        )

        sut.open()
        #expect(expectedURL == bannerURL)
    }

    @Test
    func open_callsDidSelectAction() {
        let bannerURL = Constants.API.govukBaseUrl
        var didSelectCalled: Bool = false
        let sut = EmergencyBannerWidgetViewModel(
            banner: .init(
                id: "emergency_two",
                title: "National Emergency",
                body: "This is a Level 1 emergency",
                link: .init(title: "More information",
                            url: bannerURL),
                type: "national-emergency",
                allowsDismissal: true
            ),
            analyticsService: MockAnalyticsService(),
            sortPriority: 1,
            openURLAction: { _ in },
            didSelectAction: {
                didSelectCalled = true
            },
            dismissAction: { }
        )

        sut.open()
        #expect(didSelectCalled)
    }

    @Test
    func dismiss_withLink_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let bannerURL = Constants.API.govukBaseUrl
        let sut = EmergencyBannerWidgetViewModel(
            banner: .init(
                id: "emergency_two",
                title: "National Emergency",
                body: "This is a Level 1 emergency",
                link: .init(title: "More information",
                            url: bannerURL),
                type: "national-emergency",
                allowsDismissal: true
            ),
            analyticsService: mockAnalyticsService,
            sortPriority: 1,
            openURLAction: { _ in },
            didSelectAction: { },
            dismissAction: { }
        )

        sut.dismiss()

        let functionEvent = mockAnalyticsService._trackedEvents.first

        #expect(functionEvent?.params?["text"] as? String == "More information")
        #expect(functionEvent?.params?["section"] as? String == "Banner")
        #expect(functionEvent?.params?["action"] as? String == "Remove")
        #expect(functionEvent?.name == "Function")
    }

    @Test
    func dismiss_withoutLink_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EmergencyBannerWidgetViewModel(
            banner: .init(
                id: "emergency_two",
                title: "National Emergency",
                body: "This is a Level 1 emergency",
                link: nil,
                type: "national-emergency",
                allowsDismissal: true
            ),
            analyticsService: mockAnalyticsService,
            sortPriority: 1,
            openURLAction: { _ in },
            didSelectAction: { },
            dismissAction: { }
        )

        sut.dismiss()

        let functionEvent = mockAnalyticsService._trackedEvents.first

        #expect(functionEvent?.params?["text"] as? String == "emergency_two")
        #expect(functionEvent?.params?["section"] as? String == "Banner")
        #expect(functionEvent?.params?["action"] as? String == "Remove")
        #expect(functionEvent?.name == "Function")
    }
}
