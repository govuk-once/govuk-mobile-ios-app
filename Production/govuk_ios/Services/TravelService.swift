import Foundation
import GovKit

protocol TravelServiceInterface {
    func getGroups(forceRefresh: Bool, completion: @escaping TravelGroupResultCompletion)
    func getCountries(forceRefresh: Bool, completion: @escaping CountriesListResultCompletion)
    func invalidateCache()
}

class TravelService: TravelServiceInterface {
    private let travelServiceClient: TravelServiceClientInterface
    private let analyticsService: AnalyticsServiceInterface
    private let repository: TravelRepositoryInterface

    init(travelServiceClient: TravelServiceClientInterface,
         analyticsService: AnalyticsServiceInterface,
         repository: TravelRepositoryInterface
    ) {
        self.travelServiceClient = travelServiceClient
        self.analyticsService = analyticsService
        self.repository = repository
    }

    func getGroups(
        forceRefresh: Bool = false,
        completion: @escaping TravelGroupResultCompletion
    ) {
        if forceRefresh == false,
           let cachedGroups = repository.fetchGroups() {
            completion(.success(cachedGroups))
            return
        }

        travelServiceClient.fetchGroups(
            completion: { result in
                switch result {
                case .success(let groups):
                    self.repository.store(groups: groups)
                    completion(.success(groups))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func getCountries(
        forceRefresh: Bool = false,
        completion: @escaping CountriesListResultCompletion
    ) {
#if DEBUG
        completion(.success([
            Country(slug: "australia", country: "Australia", lastUpdated: "", synonyms: []),
            Country(slug: "brazil", country: "Brazil", lastUpdated: "", synonyms: []),
            Country(slug: "canada", country: "Canada", lastUpdated: "", synonyms: []),
            Country(slug: "france", country: "France", lastUpdated: "", synonyms: []),
            Country(slug: "germany", country: "Germany", lastUpdated: "", synonyms: []),
            Country(slug: "italy", country: "Italy", lastUpdated: "", synonyms: []),
            Country(slug: "japan", country: "Japan", lastUpdated: "", synonyms: []),
            Country(slug: "spain", country: "Spain", lastUpdated: "", synonyms: []),
            Country(slug: "united-kingdom", country: "United Kingdom",
                    lastUpdated: "", synonyms: ["uk"]
                   ),
            Country(slug: "united-states", country: "United States",
                    lastUpdated: "", synonyms: ["us"]
                   )
        ]))
        return
#endif

        if forceRefresh == false,
           let cachedCountriesList = repository.fetchCountries() {
            completion(.success(cachedCountriesList))
            return
        }

        travelServiceClient.fetchCountries(
            completion: { result in
                switch result {
                case .success(let countries):
                    self.repository.store(countries: countries)
                    completion(.success(countries))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func invalidateCache() {
        repository.clear()
    }
}
