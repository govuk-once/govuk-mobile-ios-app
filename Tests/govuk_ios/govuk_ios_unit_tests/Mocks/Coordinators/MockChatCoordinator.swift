import Foundation

@testable import govuk_ios

class MockChatCoordinator: ChatCoordinator {
    var _stubbedDidShowOnboarding = false
    override func showChatOnboardingIfNecessary() {
        _stubbedDidShowOnboarding = true
    }
}
