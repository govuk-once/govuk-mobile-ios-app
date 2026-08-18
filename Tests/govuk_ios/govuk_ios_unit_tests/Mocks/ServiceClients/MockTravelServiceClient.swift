import Foundation

@testable import govuk_ios

class MockTravelServiceClient: TravelServiceClientInterface {
    var _fetchGroupsCallCount = 0
    var _receivedFetchGroupsCompletion: TravelGroupResultCompletion?

    func fetchGroups(completion: @escaping TravelGroupResultCompletion) {
        _fetchGroupsCallCount += 1
        _receivedFetchGroupsCompletion = completion
    }
}
