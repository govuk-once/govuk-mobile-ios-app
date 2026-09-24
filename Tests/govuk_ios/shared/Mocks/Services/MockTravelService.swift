import Foundation

@testable import govuk_ios

class MockTravelService: TravelServiceInterface {
    var _getGroupsCalled = false
    var _receivedGetGroupsCompletion: TravelGroupResultCompletion?
    var _getGroupsCompletion: (() -> Void)?

    var _getCountriesCalled = false
    var _receivedGetCountriesCompletion: CountriesListResultCompletion?
    var _getCountriesCompletion: (() -> Void)?

    var _stubbedGetGroupsResult: TravelGroupResult?
    var _stubbedGetCountriesResult: CountriesListResult?
    func getGroups(
        forceRefresh: Bool,
        completion: @escaping TravelGroupResultCompletion
    ) {
        _getGroupsCalled = true
        _receivedGetGroupsCompletion = completion

        if let result = _stubbedGetGroupsResult {
            completion(result)
        } else {
            completion(.failure(.apiUnavailable))
        }

        _getGroupsCompletion?()
    }

    func getCountries(
        forceRefresh: Bool, completion:
        @escaping CountriesListResultCompletion
    ) {
        _getCountriesCalled = true
        _receivedGetCountriesCompletion = completion

        if let result = _stubbedGetCountriesResult {
            completion(result)
        } else {
            completion(.failure(.apiUnavailable))
        }

        _getCountriesCompletion?()
    }


    var _invalidateCacheCalled = false
    func invalidateCache() {
        _invalidateCacheCalled = true
    }

    var _subscribeToGroupsCalled = false
    var _receivedSubscribeSlug: String?
    var _receivedSubscribeCompletion: SubscriptionResultCompletion?
    var _stubbedSubscribeResult: SubscriptionResult?
    var _autoCallSubscribeCompletion = true

    func subscribeToCountry(slug: String, completion: @escaping SubscriptionResultCompletion) {
        _subscribeToGroupsCalled = true
        _receivedSubscribeSlug = slug
        _receivedSubscribeCompletion = completion

        if _autoCallSubscribeCompletion {
            if let result = _stubbedSubscribeResult {
                completion(result)
            } else {
                completion(.success(()))
            }
        }
    }

    var _invalidateGroupsCalled = false
    func invalidateGroups() {
        _invalidateGroupsCalled = true
    }

    var _invalidateCountriesCalled = false
    func invalidateCountries() {
        _invalidateCountriesCalled = true
    }

    var _toggleNotificationsCalled = false
    var _receivedToggleNotificationSlug: String?
    var _recievedToggleNotificationEnabled: Bool?
    var _receivedToggleNotificationCompletion: SubscriptionResultCompletion?
    var _stubbedToggleResult: SubscriptionResult?
    var _autoCallToggleCompletion = true

    func toggleNotifications(slug: String, enabled: Bool, completion: @escaping SubscriptionResultCompletion) {
        _toggleNotificationsCalled = true
        _receivedToggleNotificationSlug = slug
        _recievedToggleNotificationEnabled = enabled
        _receivedToggleNotificationCompletion = completion

        if _autoCallToggleCompletion {
            if let result = _stubbedToggleResult {
                completion(result)
            } else {
                completion(.success(()))
            }
        }
    }

    var _unfollowCountryCalled = false
    var _receivedUnfollowCountrySlug: String?
    var _recievedUnfollowCountryEnabled: Bool?
    var _receivedUnfollowCountryCompletion: SubscriptionResultCompletion?
    var _stubbedUnfollowResult: SubscriptionResult?
    var _autoCallUnfollowCompletion = true

    func unfollowCountry(slug: String, currentNotificationsEnabled: Bool, completion: @escaping SubscriptionResultCompletion) {
        _unfollowCountryCalled = true
        _receivedUnfollowCountrySlug = slug
        _recievedUnfollowCountryEnabled = currentNotificationsEnabled
        _receivedUnfollowCountryCompletion = completion

        if _autoCallUnfollowCompletion {
            if let result = _stubbedUnfollowResult {
                completion(result)
            } else {
                completion(.success(()))
            }
        }
    }
}
