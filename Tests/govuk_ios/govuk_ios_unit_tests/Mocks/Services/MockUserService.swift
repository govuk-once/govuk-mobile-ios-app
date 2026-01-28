import Foundation

@testable import govuk_ios

class MockUserService: UserServiceInterface {

    var _fetchUserStateCompletionBlock: (() -> Void)?
    var _stubbedFetchUserStateResult: UserStateResult?
    func fetchUserState(completion: @escaping FetchUserStateCompletion) {
        if let result = _stubbedFetchUserStateResult {
            completion(result)
        }
        _fetchUserStateCompletionBlock?()
    }
    
}
