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
}
