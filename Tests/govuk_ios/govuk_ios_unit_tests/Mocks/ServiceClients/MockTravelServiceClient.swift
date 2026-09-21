import Foundation

@testable import govuk_ios

class MockTravelServiceClient: TravelServiceClientInterface {

    
    var _fetchGroupsCallCount = 0
    var _receivedFetchGroupsCompletion: TravelGroupResultCompletion?
    var _fetchCountriesCallCount = 0
    var _receivedFetchCountriesCompletion: CountriesListResultCompletion?

    var _subscribeToGroupsCallCount = 0
    var _receivedSubscribeSlug: String?
    var _receivedSubscribeCompletion: SubscriptionResultCompletion?

    func fetchGroups(completion: @escaping TravelGroupResultCompletion) {
        _fetchGroupsCallCount += 1
        _receivedFetchGroupsCompletion = completion
    }

    func fetchCountries(completion: @escaping CountriesListResultCompletion) {
        _fetchCountriesCallCount += 1
        _receivedFetchCountriesCompletion = completion
    }

    func subscribeToGroups(slug: String, completion: @escaping SubscriptionResultCompletion) {
        _subscribeToGroupsCallCount += 1
        _receivedSubscribeSlug = slug
        _receivedSubscribeCompletion = completion
    }
}
