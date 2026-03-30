import Foundation
import UIKit
import AuthenticationServices

protocol DVLAAuthSessionBuilderInterface {
    func session(window: UIWindow) -> DVLAAuthSessionInterface
}

class DVLAAuthSessionBuilder: DVLAAuthSessionBuilderInterface {
    func session(window: UIWindow) -> DVLAAuthSessionInterface {
        DVLAAuthSession(
            window: window,
            sessionType: ASWebAuthenticationSession.self
        )
    }
}
