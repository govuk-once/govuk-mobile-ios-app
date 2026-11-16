import Foundation
import Testing
import GovKit

@testable import govuk_ios

@MainActor
struct LicenceCategoriesViewModelTests {
    @Test
    func init_setsDefaultAndProvidedProperties() throws {
        let mockURL = try #require(URL(string: "https://www.gov.uk/driving-licence-categories"))
        let mockLink = CategoryLink(text: "Driving licence categories", url: mockURL)

        let sut = LicenceCategoriesViewModel(
            showsRowHighlight: false,
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: {}
            ),
            links: [mockLink],
            analyticsService: MockAnalyticsService()
        )

        #expect(sut.entitledToDrive.isEmpty)
        #expect(sut.provisionallyEntitledToDrive.isEmpty)
        #expect(sut.showsRowHighlight == false)
        #expect(sut.links == [mockLink])
    }

    @Test
    func convenienceInit_mapsEntitlementsCorrectly() {
        let fullEntitlement = Entitlement.arrange(
            categoryCode: "B",
            categoryType: .full
        )
        let provisionalEntitlement = Entitlement.arrange(
            categoryCode: "A",
            categoryType: .provisional
        )

        let sut = LicenceCategoriesViewModel(
            entitlements: [fullEntitlement, provisionalEntitlement],
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: {}
            ),
            links: [],
            analyticsService: MockAnalyticsService()
        )

        #expect(sut.showsRowHighlight == true)
        #expect(sut.entitledToDrive.count == 1)
        #expect(sut.provisionallyEntitledToDrive.count == 1)
    }

    @Test
    func trackScreen_tracksScreenEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LicenceCategoriesViewModel(
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: {}
            ),
            links: [],
            analyticsService: mockAnalyticsService
        )
        let mockScreen = TestTrackableScreen(trackingName: "Licence Categories")

        sut.trackScreen(screen: mockScreen)

        let trackedScreen = try #require(mockAnalyticsService._trackScreenReceivedScreens.first)
        #expect(trackedScreen.trackingName == "Licence Categories")
    }

    @Test
    func dismiss_tracksDismissEventAndCallsDismissAction() throws {
        let mockAnalyticsService = MockAnalyticsService()
        var dismissCalled = false
        let sut = LicenceCategoriesViewModel(
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: {
                    dismissCalled = true
                }
            ),
            links: [],
            analyticsService: mockAnalyticsService
        )

        sut.dismiss()

        #expect(dismissCalled)
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Back")
        #expect(trackedEvent.params?["external"] as? Bool == false)
        #expect(trackedEvent.params?["section"] as? String == "Driving")
    }

    @Test
    func onRowTap_tracksEventAndCallsDidSelectAction() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockEntitlement = Entitlement.arrange(categoryCode: "B")
        var selectedEntitlement: Entitlement?
        let sut = LicenceCategoriesViewModel(
            actions: CategoriesActions(
                didSelectAction: { entitlement in
                    selectedEntitlement = entitlement
                },
                openURLAction: nil,
                dismissAction: {}
            ),
            links: [],
            analyticsService: mockAnalyticsService
        )

        sut.onRowTap(mockEntitlement)

        #expect(selectedEntitlement?.categoryCode == "B")
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Vehicle Category")
        #expect(trackedEvent.params?["external"] as? Bool == false)
        #expect(trackedEvent.params?["section"] as? String == "Driving")
    }

    @Test
    func onLinkClick_whenNoOpenURLAction_onlyTracksEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockURL = try #require(URL(string: "https://www.gov.uk/driving-licence-categories"))
        let mockLink = CategoryLink(text: "Driving licence categories", url: mockURL)
        let sut = LicenceCategoriesViewModel(
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: {}
            ),
            links: [mockLink],
            analyticsService: mockAnalyticsService
        )

        sut.onLinkClick(mockLink)

        #expect(mockAnalyticsService._trackedEvents.count == 1)
    }

    @Test
    func onLinkClick_tracksEventAndCallsOpenURLAction() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockURL = try #require(URL(string: "https://www.gov.uk/driving-licence-categories"))
        let mockLink = CategoryLink(text: "Driving licence categories", url: mockURL)
        var openedURL: URL?
        let sut = LicenceCategoriesViewModel(
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: { url in
                    openedURL = url
                },
                dismissAction: {}
            ),
            links: [mockLink],
            analyticsService: mockAnalyticsService
        )

        sut.onLinkClick(mockLink)

        #expect(openedURL == mockURL)
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Driving licence categories")
        #expect(trackedEvent.params?["url"] as? String == "https://www.gov.uk/driving-licence-categories")
        #expect(trackedEvent.params?["external"] as? Bool == true)
        #expect(trackedEvent.params?["section"] as? String == "Driving")
    }
}

private struct TestTrackableScreen: TrackableScreen {
    let trackingName: String
    let trackingClass: String = "TestTrackableScreen"
    let trackingTitle: String? = nil
}
