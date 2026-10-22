import Foundation

@testable import govuk_ios

class MockVoiceOverFocusService: VoiceOverFocusServiceInterface {
    var _receivedFocusHeaderLabel: String?
    func focusHeader(labelled label: String) async {
        _receivedFocusHeaderLabel = label
    }
}
