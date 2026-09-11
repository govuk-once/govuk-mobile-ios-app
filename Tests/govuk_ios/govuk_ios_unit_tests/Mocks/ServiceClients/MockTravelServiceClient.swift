import Foundation

@testable import govuk_ios

class MockTravelServiceClient: TravelServiceClientInterface {

    
    var _fetchGroupsCallCount = 0
    var _receivedFetchGroupsCompletion: TravelGroupResultCompletion?
    var _fetchCountriesCallCount = 0
    var _receivedFetchCountriesCompletion: CountriesListResultCompletion?

    func fetchGroups(completion: @escaping TravelGroupResultCompletion) {
        _fetchGroupsCallCount += 1
        _receivedFetchGroupsCompletion = completion
    }

    func fetchCountries(completion: @escaping CountriesListResultCompletion) {
        _fetchCountriesCallCount += 1
        _receivedFetchCountriesCompletion = completion
    }
}
