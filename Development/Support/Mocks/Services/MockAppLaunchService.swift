import Foundation

@testable import govuk_ios

class MockAppLaunchService: AppLaunchServiceInterface {
    var _stubbedFetchAppLaunchResponse: AppLaunchResponse?
    var _receivedFetchCompletion: ((sending AppLaunchResponse) -> Void)?
    func fetch(completion: @escaping (sending AppLaunchResponse) -> Void) {
        _receivedFetchCompletion = completion
        if let response = _stubbedFetchAppLaunchResponse {
            completion(response)
        }
    }
}
