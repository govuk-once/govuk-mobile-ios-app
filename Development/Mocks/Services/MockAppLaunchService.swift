#if DEBUG
import Foundation

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
#endif // DEBUG
