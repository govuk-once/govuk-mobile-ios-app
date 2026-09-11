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
        // Implement caching and real API handling

        completion(.success([
            Country(
                name: "France",
                slug: "france",
                rawLastUpdate: "2024-01-01T00:00:00Z",
                synonyms: []
            ),
            Country(
                name: "Germany",
                slug: "germany",
                rawLastUpdate: "2024-01-01T00:00:00Z",
                synonyms: []
            ),
            Country(
                name: "Spain",
                slug: "spain",
                rawLastUpdate: "2024-01-01T00:00:00Z",
                synonyms: []
            )
        ]))
        return
    }

    func invalidateCache() {
        repository.clear()
    }
}
