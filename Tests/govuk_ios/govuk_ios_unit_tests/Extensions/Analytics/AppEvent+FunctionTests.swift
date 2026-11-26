import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct AppEvent_FunctionTests {
    @Test(arguments: [
        (NotificationPermissionResultType.system, true, "System", "Granted"),
        (NotificationPermissionResultType.system, false, "System", "Denied"),
        (NotificationPermissionResultType.settings, true, "Settings", "Granted"),
        (NotificationPermissionResultType.settings, false, "Settings", "Denied")
    ])
    func notificationPermissionResult_returnsExpectedResult(
        type: NotificationPermissionResultType,
        granted: Bool,
        expectedType: String,
        expectedAction: String
    ) {
        let result = AppEvent.notificationPermissionResult(
            type: type,
            section: "Travel Abroad Notifications",
            granted: granted
        )

        #expect(result.name == "Function")
        #expect(result.params?["text"] as? String == "Notification permission")
        #expect(result.params?["type"] as? String == expectedType)
        #expect(result.params?["action"] as? String == expectedAction)
        #expect(result.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test(arguments: [(true, "On"), (false, "Off")])
    func toggle_returnsExpectedResult(isOn: Bool, expectedAction: String) {
        let result = AppEvent.toggle(
            text: "France",
            section: "Travel Abroad Notifications",
            isOn: isOn
        )

        #expect(result.name == "Function")
        #expect(result.params?["text"] as? String == "France")
        #expect(result.params?["type"] as? String == "Toggle")
        #expect(result.params?["action"] as? String == expectedAction)
    }
}
