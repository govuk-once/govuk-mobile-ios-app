import Foundation

typealias TravelGroupResultCompletion = (sending TravelGroupResult) -> Void
typealias TravelGroupResult = Result<[TravelGroup], TravelError>
typealias CountriesListResultCompletion = (sending CountriesListResult) -> Void
typealias CountriesListResult = Result<[Country], TravelError>
typealias SubscriptionResultCompletion = (sending SubscriptionResult) -> Void
typealias SubscriptionResult = Result<Void, TravelError>

protocol TravelServiceClientInterface {
    func fetchGroups(completion: @escaping TravelGroupResultCompletion)
    func fetchCountries(completion: @escaping CountriesListResultCompletion)
    func followCountry(
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
}

class TravelServiceClient: TravelServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface

    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchGroups(completion: @escaping TravelGroupResultCompletion) {
        apiServiceClient.send(
            request: .travelGroups,
            completion: { result in
                completion(self.handleResponse(result))
            }
        )
    }

    func fetchCountries(completion: @escaping CountriesListResultCompletion) {
        apiServiceClient.send(
            request: .countriesList,
            completion: { result in
                completion(self.handleResponse(result))
            }
        )
    }

    func followCountry(
        slug: String,
        notificationsEnabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    ) {
        let (leaveSubgroup, joinSubgroup) = notificationsEnabled
        ? (SubscriptionRequest.SubscriptionGroup.NONE,
           SubscriptionRequest.SubscriptionGroup.INSTANT)
        : (SubscriptionRequest.SubscriptionGroup.INSTANT,
           SubscriptionRequest.SubscriptionGroup.NONE)

        let body = [
            SubscriptionRequest(
                namespace: "travel",
                group: slug,
                subgroup: leaveSubgroup,
                type: .notification,
                action: .leave
            ), SubscriptionRequest(
                namespace: "travel",
                group: slug,
                subgroup: joinSubgroup,
                type: .notification,
                action: .join
            )
        ]

        let request = GOVRequest.subscribeToGroups(
            subscriptionsBody: body
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    let travelError = self.mapError(error)
                    completion(.failure(travelError))
                }
            }
        )
    }

    func toggleNotifications(
        slug: String,
        enabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    ) {
        let (leaveSubgroup, joinSubgroup) = enabled
        ? (SubscriptionRequest.SubscriptionGroup.NONE,
           SubscriptionRequest.SubscriptionGroup.INSTANT)
        : (SubscriptionRequest.SubscriptionGroup.INSTANT,
           SubscriptionRequest.SubscriptionGroup.NONE)

        let body = [
            SubscriptionRequest(
                namespace: "travel",
                group: slug,
                subgroup: leaveSubgroup,
                type: .notification,
                action: .leave
            ), SubscriptionRequest(
                namespace: "travel",
                group: slug,
                subgroup: joinSubgroup,
                type: .notification,
                action: .join
            )
        ]

        let request = GOVRequest.subscribeToGroups(
            subscriptionsBody: body
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    let travelError = self.mapError(error)
                    completion(.failure(travelError))
                }
            }
        )
    }

    func unfollowCountry(
        slug: String,
        currentNotificationsEnabled: Bool,
        completion: @escaping SubscriptionResultCompletion
    ) {
        let subgroupToLeave = currentNotificationsEnabled
        ? SubscriptionRequest.SubscriptionGroup.INSTANT
        : SubscriptionRequest.SubscriptionGroup.NONE

        let request = GOVRequest.subscribeToGroups(
            subscriptionsBody: [SubscriptionRequest(
                namespace: "travel",
                group: slug,
                subgroup: subgroupToLeave,
                type: .notification,
                action: .leave
            )]
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    let travelError = self.mapError(error)
                    completion(.failure(travelError))
                }
            }
        )
    }

    private func handleResponse<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, TravelError> {
        return result.mapError { error in
            mapError(error)
        }.flatMap { data in
            do {
                let travelResult: T = try JSONDecoder().decode(from: data)
                return .success(travelResult)
            } catch _ as DecodingError {
                return .failure(TravelError.decodingError)
            } catch {
                return .failure(TravelError.unknown)
            }
        }
    }

    private func mapError(_ error: Error) -> TravelError {
        let nsError = (error as NSError)
        if nsError.code == NSURLErrorNotConnectedToInternet {
            return TravelError.networkUnavailable
        } else if let travelError = error as? TravelError {
            return travelError
        } else if error is TokenRefreshError {
            return TravelError.authenticationError
        } else {
            return TravelError.apiUnavailable
        }
    }
}

enum TravelError: Error {
    case apiUnavailable
    case networkUnavailable
    case decodingError
    case authenticationError
    case unknown
}

struct TravelResponseHandler: ResponseHandler {
    func handleStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        case 401, 403:
            TravelError.authenticationError
        default:
            TravelError.apiUnavailable
        }
    }
}
