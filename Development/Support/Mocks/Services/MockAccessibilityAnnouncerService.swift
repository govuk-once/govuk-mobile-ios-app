#if DEBUG
import Foundation

class MockAccessibilityAnnouncerService: AccessibilityAnnouncerServiceInterface {
    var _receivedAnnounceValue: String?
    func announce(_ value: String) {
        _receivedAnnounceValue = value
    }
}
#endif // DEBUG
