import Foundation

@testable import govuk_ios

class MockDVLAService: DVLAServiceInterface {
    var _linkAccountCallCount = 0
    var _stubbedLinkAccountResult: LinkAccountResult?
    func linkAccount(linkId: String, completion: @escaping LinkAccountCompletion) {
        _linkAccountCallCount += 1
        if let result = _stubbedLinkAccountResult {
            completion(result)
        }
    }

}
