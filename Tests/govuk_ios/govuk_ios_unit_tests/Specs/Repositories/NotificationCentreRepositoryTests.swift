import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
class NotificationCentreRepositoryTests {
    class MockDateProvider: NotificationCentreRepository.DateProvider {
        var _mockDate: Date = Date()

        override var currentDate: Date {
            _mockDate
        }
    }

    let mockDateProvider: MockDateProvider!
    let SUT: NotificationCentreRepositoryInterface!

    var dateForTest = Date()

    init() {
        mockDateProvider = .init()
        SUT = NotificationCentreRepository(dateProvider: mockDateProvider)
    }

    @Test
    func store_retrievesCorrectly() {
        let testObjs = NotificationCentreViewModel.MockData.testNotifications.recent

        SUT.store(notifications: testObjs)

        let stored = SUT.fetchAll()

        #expect(stored == testObjs)
    }

    @Test
    func retrieve_onceExpired_fails() {
        let testObjs = NotificationCentreViewModel.MockData.testNotifications.recent

        // Set it back 10 minutes
        mockDateProvider._mockDate = dateForTest.addingTimeInterval(-600)

        SUT.store(notifications: testObjs)

        // Move it back to now
        mockDateProvider._mockDate = Date()

        let stored = SUT.fetchAll()

        #expect(stored.isEmpty)
    }

    @Test
    func retrieve_single_returnsExpectedValue() throws {
        let testObjs = NotificationCentreViewModel.MockData.testNotifications.recent

        SUT.store(notifications: testObjs)

        let stored = try #require(SUT.fetchNotification(with: "3"))

        #expect(stored.id == "3")
        #expect(stored.body == "Body 3 read")
    }

    @Test
    func retrieve_single_withInvalidID_returnsNil() {
        let testObjs = NotificationCentreViewModel.MockData.testNotifications.recent

        SUT.store(notifications: testObjs)

        let stored = SUT.fetchNotification(with: "invalid")

        #expect(stored == nil)
    }

    @Test
    func delete_updatesAll() {
        let testObjs = NotificationCentreViewModel.MockData.testNotifications.recent

        SUT.store(notifications: testObjs)

        SUT.deleteNotification(with: "4")

        let stored = SUT.fetchAll()

        #expect(stored.count == 6)

        let deleted = stored.first(where: { $0.id == "4" })
        #expect(deleted == nil)
    }

    @Test
    func update_setsFlagCorrectly() throws {
        let testObjs = NotificationCentreViewModel.MockData.testNotifications.recent

        SUT.store(notifications: testObjs)

        SUT.updateNotification(with: "5", isUnread: true)

        let stored = try #require(SUT.fetchNotification(with: "5"))

        #expect(stored.isUnread)
    }
}
