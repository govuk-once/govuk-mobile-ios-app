import Foundation

@testable import govuk_ios

class MockUserServiceClient: UserServiceClientInterface {

    var _stubbedFetchUserStateResult: UserStateResult?
    func fetchUserState(completion: @escaping FetchUserStateCompletion) {
        if let result = _stubbedFetchUserStateResult {
            completion(result)
        }

    }
    
}

