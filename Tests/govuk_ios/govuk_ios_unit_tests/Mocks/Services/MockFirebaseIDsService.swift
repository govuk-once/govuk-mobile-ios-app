import Foundation
import Testing

@testable import govuk_ios

class MockFirebaseIDsService: FirebaseIDsServiceInterface {
    private(set) var appInstanceID: String = "123"
    private(set) var sessionID: String = "321"

    var _updateSessionIDCalled = false
    func updateSessionID() {
        _updateSessionIDCalled = true
    }
}
