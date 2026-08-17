import Foundation

typealias TravelGroupResultCompletion = (sending TravelGroupResult) -> Void
typealias TravelGroupResult = Result<[TravelGroup], TravelError>

protocol TravelServiceClientInterface {
    func fetchGroups(completion: @escaping TravelGroupResultCompletion)
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

    private func handleResponse<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, TravelError> {
        return result.mapError { error in
            let nsError = (error as NSError)
            if nsError.code == NSURLErrorNotConnectedToInternet {
                return TravelError.networkUnavailable
            } else {
                return TravelError.apiUnavailable
            }
        }.flatMap { data in
            do {
                let travelResult: T = try JSONDecoder().decode(from: data)
                return .success(travelResult)
            } catch let error as DecodingError {
                return .failure(TravelError.decodingError)
            } catch {
                return .failure(TravelError.unknown)
            }
        }
    }
}

enum TravelError: Error {
    case apiUnavailable
    case networkUnavailable
    case decodingError
    case unknown
}
