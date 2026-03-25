import Foundation
import UIKit

@testable import govuk_ios

class MockDVLAAuthenticationService: DVLAAuthenticationServiceInterface {

    var _stubbedAuthenticationResult: DVLAAuthResult = .failure(.unknown)
    func authenticate(window: UIWindow) async -> DVLAAuthResult {
        _stubbedAuthenticationResult
    }
    
}

