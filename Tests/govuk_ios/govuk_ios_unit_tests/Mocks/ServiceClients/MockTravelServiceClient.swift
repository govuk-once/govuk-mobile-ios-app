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

    var _toggleNotificationsCallCount = 0
    var _receivedToggleSlug: String?
    var _receivedToggleEnabled: Bool?
    var _receivedToggleCompletion: SubscriptionResultCompletion?

    var _unfollowCallCount = 0
    var _receivedUnfollowSlug: String?
    var _receivedUnfollowEnabled: Bool?
    var _receivedUnfollowCompletion: SubscriptionResultCompletion?

    func fetchGroups(completion: @escaping TravelGroupResultCompletion) {
        _fetchGroupsCallCount += 1
        _receivedFetchGroupsCompletion = completion
    }

    func fetchCountries(completion: @escaping CountriesListResultCompletion) {
        _fetchCountriesCallCount += 1
        _receivedFetchCountriesCompletion = completion
    }

    func subscribeToCountry(slug: String, completion: @escaping SubscriptionResultCompletion) {
        _subscribeToGroupsCallCount += 1
        _receivedSubscribeSlug = slug
        _receivedSubscribeCompletion = completion
    }

    func toggleNotifications(slug: String, enabled: Bool, completion: @escaping govuk_ios.SubscriptionResultCompletion) {
        _toggleNotificationsCallCount += 1
        _receivedToggleSlug = slug
        _receivedToggleEnabled = enabled
        _receivedToggleCompletion = completion
    }

    func unfollowCountry(slug: String, currentNotificationsEnabled: Bool, completion: @escaping govuk_ios.SubscriptionResultCompletion) {
        _unfollowCallCount += 1
        _receivedUnfollowSlug = slug
        _receivedUnfollowEnabled = currentNotificationsEnabled
        _receivedUnfollowCompletion = completion
    }
}
