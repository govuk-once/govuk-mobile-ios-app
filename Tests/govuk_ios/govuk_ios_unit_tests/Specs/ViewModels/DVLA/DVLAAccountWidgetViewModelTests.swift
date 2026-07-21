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
    func fetchLinkedAccount_failure_updatesViewStateWithErrorViewModel() async throws {
        let mockDvlaAccountURL = URL(string: "https://dvla.gov.uk/account")!
        mockConfigService._dvlaUrls = .arrange(account: mockDvlaAccountURL.absoluteString)
        mockUserService._stubbedFetchLinkedAccountsResult = .failure(.apiUnavailable)
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            actions: .empty
        )
        await sut.fetchLinkedAccounts()
        var errorViewModel: InlineActionErrorViewModel?
        if case .error(let error) = sut.viewState {
            errorViewModel = error
        }
        let unwrappedErrorViewModel = try #require(errorViewModel)
        let expectedButtonTitle = String(localized: .DVLA.accountWidgetErrorButtonTitle)
        let expectedMarkdownBody = String(
            localized: .DVLA.accountWidgetErrorBody(
                buttonTitle: expectedButtonTitle,
                url: mockDvlaAccountURL.absoluteString
            )
        )
        #expect(unwrappedErrorViewModel.title == String(localized: .DVLA.accountWidgetErrorTitle))
        #expect(unwrappedErrorViewModel.markdownBody == expectedMarkdownBody)
    }

    @Test
    func linkedAccountsErrorViewModelAction_tracksNavigationEvent() async throws {
        let mockDvlaAccountURL = URL(string: "https://dvla.gov.uk/account")!
        mockUserService._stubbedFetchLinkedAccountsResult = .failure(.apiUnavailable)
        let sut = DVLAAccountWidgetViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            actions: .empty
        )
        await sut.fetchLinkedAccounts()
        var errorViewModel: InlineActionErrorViewModel?
        if case .error(let error) = sut.viewState {
            errorViewModel = error
        }
        let unwrappedErrorViewModel = try #require(errorViewModel)
        unwrappedErrorViewModel.openURLAction(mockDvlaAccountURL)
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == String(localized: .DVLA.accountWidgetErrorButtonTitle))
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["url"] as? String == mockDvlaAccountURL.absoluteString)
        #expect(trackedEvent.params?["external"] as? Bool == true)
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

        var accountSummaryViewModel: DVLAAccountSummaryViewModel?
        if case .linked(let accountSummary) = sut.viewState {
            accountSummaryViewModel = accountSummary
        }
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
                vehicleDetailAction: { _ in },
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
            vehicleDetailAction: { _ in },
            openURLAction: { _ in }
        )
    }
}
