import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DVLAAccountWidgetViewModelTests {

    var mockAnalyticsService: MockAnalyticsService
    var mockDvlaService: MockDVLAService
    var mockUserService: MockUserService
    var mockConfigService: MockAppConfigService

    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockDvlaService = MockDVLAService()
        mockUserService = MockUserService()
        mockConfigService = MockAppConfigService()
    }

    @Test
    func viewDidAppear_whenLinkedAccountsNotCached_fetchesLinkedAccounts() async {
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])
        mockUserService._stubbedLinkedAccounts = nil
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            actions: .empty,
        )
        await sut.viewDidAppear()
        #expect(mockUserService._fetchLinkedAccountsCalled == true)
    }

    @Test
    func viewDidAppear_accountIsLinked_updatesStateToLinked() async throws {
        mockUserService._stubbedLinkedAccounts = [.dvla]
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            actions: .empty
        )
        await sut.viewDidAppear()

        var actionCards: [ListCardViewModel]?
        var accountSummaryViewModel: DVLAAccountSummaryViewModel?
        if case .linked(let cards, let accountSummary) = sut.viewState {
            actionCards = cards
            accountSummaryViewModel = accountSummary
        }
        #expect(actionCards?.count == 4)
        #expect(actionCards?.first?.title == String.dvla.localized("dvlaAccountUnlinkCardTitle"))
        #expect(accountSummaryViewModel != nil)
    }

    @Test
    func viewDidAppear_accountIsNotLinked_createsLinkCardViewModel() async throws {
        mockUserService._stubbedLinkedAccounts = []
        var linkActionCalled = false
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            actions: .init(
                linkAction: {
                    linkActionCalled = true
                },
                unlinkAction: {},
                vehicleDetailAction: { _ in },
                viewVehicleAction: {},
                viewShareCodesAction: {},
                createShareCodeAction: {},
                openURLAction: { _ in }
            )
        )
        await sut.viewDidAppear()
        var linkCardViewModel: ServiceAccountLinkCardViewModel?
        if case .unlinked(let linkCard) = sut.viewState {
            linkCardViewModel = linkCard
        }
        #expect(linkCardViewModel?.title == String.dvla.localized("dvlaAccountLinkCardTitle"))
        #expect(linkCardViewModel?.subtitle == String.dvla.localized("dvlaAccountLinkCardSubtitle"))
        linkCardViewModel?.action()
        #expect(linkActionCalled == true)
    }

    @Test
    func linkCardViewModelAction_tracksNavigationEvent() async {
        mockUserService._stubbedLinkedAccounts = []
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            actions: .empty
        )
        await sut.viewDidAppear()

        var linkCardViewModel: ServiceAccountLinkCardViewModel?
        if case .unlinked(let linkCard) = sut.viewState {
            linkCardViewModel = linkCard
        }
        linkCardViewModel?.action()

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
            vehicleDetailAction: { _ in },
            viewVehicleAction: {},
            viewShareCodesAction: {},
            createShareCodeAction: {},
            openURLAction: { _ in }
        )
    }
}
