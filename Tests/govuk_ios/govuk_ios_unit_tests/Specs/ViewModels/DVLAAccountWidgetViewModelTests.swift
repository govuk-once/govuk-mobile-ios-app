import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DVLAAccountWidgetViewModelTests {

    var mockAnalyticsService: MockAnalyticsService
    var mockDvlaService: MockDVLAService
    var mockUserService: MockUserService

    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockDvlaService = MockDVLAService()
        mockUserService = MockUserService()
    }

    @Test
    func viewDidAppear_whenAccountLinkStatusNotCached_fetchesLinkStatus() async {
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeLinked)
        mockUserService._stubbedIsDvlaAccountLinked = nil
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            actions: .empty
        )
        await sut.viewDidAppear()
        #expect(mockUserService._fetchAccountLinkStatusCalled == true)
    }

    @Test
    func viewDidAppear_accountIsLinked_createsActionCards() async {
        mockUserService._stubbedIsDvlaAccountLinked = true
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            actions: .empty
        )
        await sut.viewDidAppear()
        #expect(sut.actionCards.count == 4)
        #expect(sut.actionCards.first?.title == String.dvla.localized("dvlaAccountUnlinkCardTitle"))
    }

    @Test
    func viewDidAppear_accountIsNotLinked_createsLinkCardViewModel() async throws {
        mockUserService._stubbedIsDvlaAccountLinked = false
        var linkActionCalled = false
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            actions: .init(
                linkAction: {
                    linkActionCalled = true
                },
                unlinkAction: {},
                viewLicenceAction: {},
                viewDriverSummaryAction: {},
                viewCustomerSummaryAction: {}
            )
        )
        await sut.viewDidAppear()
        let linkCardViewModel = try #require(sut.linkCardViewModel)
        #expect(linkCardViewModel.title == String.dvla.localized("dvlaAccountLinkCardTitle"))
        #expect(linkCardViewModel.subtitle == String.dvla.localized("dvlaAccountLinkCardSubtitle"))
        linkCardViewModel.action()
        #expect(linkActionCalled == true)
    }

    @Test
    func linkCardViewModelAction_tracksNavigationEvent() async {
        mockUserService._stubbedIsDvlaAccountLinked = false
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            actions: .empty
        )
        await sut.viewDidAppear()
        sut.linkCardViewModel?.action()

        let navigationEvent = mockAnalyticsService._trackedEvents.first
        #expect(navigationEvent?.params?["text"] as? String == "Add driver and vehicles account")
        #expect(navigationEvent?.params?["type"] as? String == "trigger card")
        #expect(navigationEvent?.params?["section"] as? String == "account link")
        #expect(navigationEvent?.name == "Navigation")
    }

}

extension DVLAAccountWidgetViewModel.Actions {
    static var empty: DVLAAccountWidgetViewModel.Actions {
        .init(
            linkAction: {},
            unlinkAction: {},
            viewLicenceAction: {},
            viewDriverSummaryAction: {},
            viewCustomerSummaryAction: {}
        )
    }
}
