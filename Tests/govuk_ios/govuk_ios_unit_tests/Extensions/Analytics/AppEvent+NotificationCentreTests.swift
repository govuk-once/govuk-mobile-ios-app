import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct AppEvent_NotificationCentreTests {

    @Test
    func urlLaunched_correctParams() {
        let urlForTest = URL(string: "https://gov.test")!

        let result = AppEvent.notificationCentreUrlLaunched(url: urlForTest)

        #expect(result.name == "NotificationCentreUrlLaunched")
        #expect(result.params?.count == 1)
        #expect(result.params?["url"] as? String == urlForTest.absoluteString)
    }

    @Test
    func notFound_correctParams() {
        let result = AppEvent.notificationCentreNotFound()

        #expect(result.name == "NotificationCentreNotFound")
        #expect(result.params == nil)
    }

    @Test
    func markUnread_correctParams() {
        let result = AppEvent.notificationCentreMarkUnread()

        #expect(result.name == "NotificationCentreMarkUnread")
        #expect(result.params == nil)
    }

    @Test
    func deleteNotification_correctParams() {
        let result = AppEvent.notificationCentreDelete()

        #expect(result.name == "NotificationCentreDelete")
        #expect(result.params?.count == 1)
        #expect(result.params?["action"] as? String == "tap")
    }

    @Test
    func confirmDeleteNotification_correctParams() {
        let result = AppEvent.notificationCentreConfirmDelete()

        #expect(result.name == "NotificationCentreDelete")
        #expect(result.params?.count == 1)
        #expect(result.params?["action"] as? String == "confirm")
    }

    @Test
    func cancelDeleteNotification_correctParams() {
        let result = AppEvent.notificationCentreCancelDelete()

        #expect(result.name == "NotificationCentreDelete")
        #expect(result.params?.count == 1)
        #expect(result.params?["action"] as? String == "cancel")
    }
}
