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
            Country(country: "Australia", slug: "australia", lastUpdate: "", synonyms: []),
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Canada", slug: "canada", lastUpdate: "", synonyms: []),
            Country(country: "France", slug: "france", lastUpdate: "", synonyms: []),
            Country(country: "Germany", slug: "germany", lastUpdate: "", synonyms: []),
            Country(country: "Italy", slug: "italy", lastUpdate: "", synonyms: []),
            Country(country: "Japan", slug: "japan", lastUpdate: "", synonyms: []),
            Country(country: "Spain", slug: "spain", lastUpdate: "", synonyms: []),
            Country(country: "United Kingdom", slug: "united-kingdom",
                    lastUpdate: "", synonyms: ["uk"]
                   ),
            Country(country: "United States", slug: "united-states",
                    lastUpdate: "", synonyms: ["us"]
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
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        )
    }

    func invalidateCache() {
        repository.clear()
    }
}
