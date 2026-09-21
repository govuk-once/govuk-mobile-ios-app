@testable import govuk_ios

final class SnapshotTravelService: TravelServiceInterface {

    private let travelGroupResult: TravelGroupResult?
    private let countryListResult: CountriesListResult?

    init(
        travelGroupResult: TravelGroupResult?,
        countryListResult: CountriesListResult? = nil
    ) {
        self.travelGroupResult = travelGroupResult
        self.countryListResult = countryListResult
    }

    func getGroups(forceRefresh: Bool, completion: @escaping TravelGroupResultCompletion) {
        guard let travelGroupResult else { return }
        completion(travelGroupResult)
    }

    func getCountries(forceRefresh: Bool, completion: @escaping CountriesListResultCompletion) {
        if let countryListResult = countryListResult {
            completion(countryListResult)
        } else {
            completion(.success([]))
        }
    }

    func subscribeToCountry(slug: String, completion: @escaping SubscriptionResultCompletion) {
        completion(.success(()))
    }

    func invalidateCache() {}

    func invalidateGroups() {}

    func invalidateCountries() {}
}
