import Foundation
import Testing

@testable import govuk_ios

@Suite
struct MailboxListViewModelTests {

    var mockMailboxService: MockMailboxService!
    var mockAnalyticsService: MockAnalyticsService!

    init() {
        mockMailboxService = MockMailboxService()
        mockAnalyticsService = MockAnalyticsService()
    }

    // `loadMessages()` hops onto the main queue asynchronously even though
    // the mock's completion fires synchronously, so tests need to yield
    // briefly for that hop to land before asserting on published state.
    private func waitForMainQueueHop() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    @Test
    func loadMessages_failureWithNoCachedMessages_setsLoadError() async {
        mockMailboxService._stubbedFetchMessagesResult = .failure(MailboxError.apiUnavailable)
        let sut = MailboxListViewModel(
            mailboxService: mockMailboxService,
            analyticsService: mockAnalyticsService,
            messageSelectedAction: { _ in }
        )

        sut.loadMessages()
        await waitForMainQueueHop()

        #expect(sut.messages.isEmpty)
        #expect(sut.loadError != nil)
        #expect(sut.refreshFailed == false)
    }

    @Test
    func loadMessages_failureWithCachedMessages_setsRefreshFailedAndKeepsMessages() async {
        let existingMessages: [MailboxMessage] = [.arrange(messageId: "message-1")]
        mockMailboxService._stubbedFetchMessagesResult = .success(existingMessages)
        let sut = MailboxListViewModel(
            mailboxService: mockMailboxService,
            analyticsService: mockAnalyticsService,
            messageSelectedAction: { _ in }
        )
        sut.loadMessages()
        await waitForMainQueueHop()
        #expect(sut.messages.count == 1)

        mockMailboxService._stubbedFetchMessagesResult = .failure(MailboxError.apiUnavailable)
        sut.loadMessages()
        await waitForMainQueueHop()

        #expect(sut.messages.count == 1)
        #expect(sut.refreshFailed == true)
        #expect(sut.loadError == nil)
    }

    @Test
    func loadMessages_successAfterFailure_clearsErrorState() async {
        mockMailboxService._stubbedFetchMessagesResult = .failure(MailboxError.apiUnavailable)
        let sut = MailboxListViewModel(
            mailboxService: mockMailboxService,
            analyticsService: mockAnalyticsService,
            messageSelectedAction: { _ in }
        )
        sut.loadMessages()
        await waitForMainQueueHop()
        #expect(sut.loadError != nil)

        mockMailboxService._stubbedFetchMessagesResult = .success([.arrange])
        sut.loadMessages()
        await waitForMainQueueHop()

        #expect(sut.loadError == nil)
        #expect(sut.refreshFailed == false)
        #expect(sut.messages.count == 1)
    }
}
