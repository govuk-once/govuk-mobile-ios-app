import Foundation
import GovKit

protocol TravelServiceInterface {
    func getGroups(completion: @escaping TravelGroupResultCompletion)
}

class TravelService: TravelServiceInterface {
    private let travelServiceClient: TravelServiceClientInterface
    private let analyticsService: AnalyticsServiceInterface

    init(travelServiceClient: TravelServiceClientInterface,
         analyticsService: AnalyticsServiceInterface) {
        self.travelServiceClient = travelServiceClient
        self.analyticsService = analyticsService
    }

    func getGroups(completion: @escaping TravelGroupResultCompletion) {
        travelServiceClient.fetchGroups(
            completion: { result in
                switch result {
                case .success(let groups):
                    completion(.success(groups))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
