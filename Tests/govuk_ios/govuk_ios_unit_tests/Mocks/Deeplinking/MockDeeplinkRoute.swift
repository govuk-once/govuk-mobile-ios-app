import Foundation

@testable import govuk_ios

class MockDeeplinkRoute: DeeplinkRoute {

    let pattern: URLPattern
    var _shouldSwitchTab: Bool = true

    init(pattern: URLPattern) {
        self.pattern = pattern
    }

    var shouldSwitchTab: Bool { _shouldSwitchTab }

    var _actionCalled: Bool = false
    func action(parent: BaseCoordinator,
                params: [String : String]) {
        _actionCalled = true
    }
}
