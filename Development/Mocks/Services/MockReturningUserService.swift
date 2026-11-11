import Foundation

class MockReturningUserService: ReturningUserServiceInterface {
    var _stubbedReturningUserResult: ReturningUserResult = .success(true)
    func process(idToken: String?) async -> govuk_ios.ReturningUserResult {
        _stubbedReturningUserResult
    }
}
