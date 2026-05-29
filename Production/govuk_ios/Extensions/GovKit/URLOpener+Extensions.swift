import Foundation

import GovKit

extension URLOpener {
    @discardableResult
    func openPrivacyPolicy() -> Bool {
        openIfPossible(Constants.API.privacyPolicyUrl)
    }
}
