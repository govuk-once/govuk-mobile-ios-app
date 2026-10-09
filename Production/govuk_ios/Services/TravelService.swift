import Foundation
import GovKit

protocol TravelServiceInterface {
    func getGroups(forceRefresh: Bool, completion: @escaping TravelGroupResultCompletion)
    func getCountries(forceRefresh: Bool, completion: @escaping CountriesListResultCompletion)
    func subscribeToCountry(
        slug: String,
        notificationsEnabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    )
    func toggleNotifications(
        slug: String,
        enabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    )
    func unfollowCountry(
        slug: String,
        currentNotificationsEnabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    )
    func invalidateGroups()
    func invalidateCountries()
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

    func subscribeToCountry(
        slug: String,
        notificationsEnabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    ) {
        travelServiceClient.followCountry(
            slug: slug,
            notificationsEnabled: notificationsEnabled,
            completion: { result in
                switch result {
                case .success:
                    self.invalidateGroups()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func toggleNotifications(
        slug: String,
        enabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    ) {
        travelServiceClient.toggleNotifications(
            slug: slug,
            enabled: enabled,
            completion: { result in
                switch result {
                case .success:
                    self.invalidateGroups()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func unfollowCountry(
        slug: String,
        currentNotificationsEnabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    ) {
        travelServiceClient.unfollowCountry(
            slug: slug,
            currentNotificationsEnabled: currentNotificationsEnabled,
            completion: { result in
                switch result {
                case .success:
                    self.invalidateGroups()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func invalidateGroups() {
        repository.invalidateGroups()
    }

    func invalidateCountries() {
        repository.invalidateCountries()
    }

    func invalidateCache() {
        repository.clear()
    }
}
