@testable import govuk_ios

class MockTravelRepository: TravelRepositoryInterface {

    var _fetchGroupsResult: [TravelGroup]?
    func fetchGroups() -> [TravelGroup]? {
        _fetchGroupsResult
    }

    var _fetchCountiresResult: [Country]?
    func fetchCountries() -> [Country]? {
        _fetchCountiresResult
    }

    var _storedGroups: [TravelGroup]?
    func store(groups: [TravelGroup]) {
        _storedGroups = groups
    }

    var _storedCountries: [Country]?
    func store(countries: [Country]) {
        _storedCountries = countries
    }

    var _clearCalled = false
    func clear() {
        _clearCalled = true
    }
}
