import Foundation
import UIKit
import Testing

@testable import govuk_ios

class MockDVLAAuthSession: DVLAAuthSessionInterface {
    init() {
        
    }
    required init(window: UIWindow, sessionType: ASWebAuthenticationSessionInterface.Type) {

    }

    var _stubbedCallbackUrl: URL?
    var _stubbedError: Error?
    func start(config: DVLAAuthSessionConfig) async throws -> URL {
        if let callbackUrl = _stubbedCallbackUrl {
            return callbackUrl
        } else if let error = _stubbedError {
            throw error
        }
        throw DVLAAuthError.unknown
    }
}

class MockDVLAAuthSessionBuilder: DVLAAuthSessionBuilderInterface {
    var _stubbedSession: MockDVLAAuthSession?
    func session(window: UIWindow) -> DVLAAuthSessionInterface {
        return _stubbedSession ?? MockDVLAAuthSession(window: window, sessionType: MockASWebAuthenticationSession.self)
    }
}
