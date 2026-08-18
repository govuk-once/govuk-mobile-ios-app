@testable import govuk_ios

class MockTravelRepository: TravelRepositoryInterface {
    var _fetchGroupsResult: [TravelGroup]?
    func fetchGroups() -> [TravelGroup]? {
        _fetchGroupsResult
    }

    var _storedGroups: [TravelGroup]?
    func store(groups: [TravelGroup]) {
        _storedGroups = groups
    }

    var _clearCalled = false
    func clear() {
        _clearCalled = true
    }
}
