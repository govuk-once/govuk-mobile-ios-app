@testable import govuk_ios

class MockTravelRepository: TravelRepositoryInterface {

    var _fetchGroupsResult: [TravelGroup]?
    func fetchGroups() -> [TravelGroup]? {
        _fetchGroupsResult
    }

    var _fetchCountriesResult: [Country]?
    func fetchCountries() -> [Country]? {
        _fetchCountriesResult
    }

    var _storedGroups: [TravelGroup]?
    func store(groups: [TravelGroup]) {
        _storedGroups = groups
    }

    var _storedCountries: [Country]?
    func store(countries: [Country]) {
        _storedCountries = countries
    }

    var _invalidateGroupsCalled = false
    func invalidateGroups() {
        _invalidateGroupsCalled = true
        _fetchGroupsResult = nil
    }

    var _invalidateCountriesCalled = false
    func invalidateCountries() {
        _invalidateCountriesCalled = true
        _fetchCountriesResult = nil
    }


    var _clearCalled = false
    func clear() {
        _clearCalled = true
        _fetchGroupsResult = nil
        _fetchCountriesResult = nil
    }
}
