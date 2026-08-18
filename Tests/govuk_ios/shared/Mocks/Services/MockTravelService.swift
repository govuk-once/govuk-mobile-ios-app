import Foundation

@testable import govuk_ios

class MockTravelService: TravelServiceInterface {
    var _getGroupsCalled = false
    var _receivedGetGroupsCompletion: TravelGroupResultCompletion?
    var _getGroupsCompletion: (() -> Void)?

    var _stubbedGetGroupsResult: TravelGroupResult?
    func getGroups(forceRefresh: Bool,
                   completion: @escaping TravelGroupResultCompletion) {
        _getGroupsCalled = true
        _receivedGetGroupsCompletion = completion

        if let result = _stubbedGetGroupsResult {
            completion(result)
        } else {
            completion(.failure(.apiUnavailable))
        }

        _getGroupsCompletion?()
    }

    var _invalidateCacheCalled = false
    func invalidateCache() {
        _invalidateCacheCalled = true
    }
}
