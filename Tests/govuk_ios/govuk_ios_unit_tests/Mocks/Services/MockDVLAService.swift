import Foundation

@testable import govuk_ios

class MockDVLAService: DVLAServiceInterface {
    var _stubbedLinkAccountResult: LinkAccountResult?
    func linkAccount(linkId: String, completion: @escaping LinkAccountCompletion) {
        if let result = _stubbedLinkAccountResult {
            completion(result)
        }
    }

}
