import Testing
@testable import govuk_ios

@Suite
struct YourAccountsViewModelTests {

    @Test
    func fetchLinkedAccounts_success_linked_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])

        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService()
        )
        await sut.fetchLinkedAccounts()
        #expect(sut.state == .success)
    }

    @Test
    func trackEvent_tracksEventsCorrectly() {
        let mockUserService = MockUserService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: mockAnalyticsService
        )
        sut.trackEvent(text: "event")

        let event = mockAnalyticsService._trackedEvents.first
        #expect(event?.params?["text"] as? String == "event")
    }

    @Test
    func trackNavigationEvent_tracksEventsCorrectly() {
        let mockUserService = MockUserService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: mockAnalyticsService
        )
        sut.trackNavigationEvent(text: "navigation")
        let event = mockAnalyticsService._trackedEvents.first
        
        #expect(event?.params?["text"] as? String == "navigation")
    }

    @Test
    func fetchLinkedAccounts_success_unliked_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([])

        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService()
        )
        await sut.fetchLinkedAccounts()
        #expect(sut.state == .empty)
    }


    @Test
    func fetchLinkedAccounts_failure_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .failure(.apiUnavailable)
        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService()
        )
        await sut.fetchLinkedAccounts()
        #expect(sut.state == .failure)
    }

    @Test
    @MainActor
    func unlinkAccount_success_updatesStateToEmpty() {
        let mockUserService = MockUserService()
        mockUserService._stubbedUnlinkAccountResult = .success(())

        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            analyticsService: MockAnalyticsService(),
        )
        sut.state = .success
        sut.unlinkAccount()

        #expect(mockUserService._unlinkAccountCallCount == 1)
        #expect(sut.state == .empty)
    }
}
