import Foundation
import Testing

@testable import govuk_ios

class MockFirebaseApp: FirebaseAppInterface {
    static var _configureCalled: Bool = false
    static func configure() {
        _configureCalled = true
    }

    static func _clearValues() {
        _configureCalled = false
    }
}

