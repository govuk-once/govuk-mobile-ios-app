import Foundation

@testable import govuk_ios

class MockDVLAServiceClient: DVLAServiceClientInterface {

    var _stubbedLinkAccountResult: LinkAccountResult?
    func linkAccount(linkId: String,
                     completion: @escaping (LinkAccountResult) -> Void) {
        if let result = _stubbedLinkAccountResult {
            completion(result)
        }
    }
}

