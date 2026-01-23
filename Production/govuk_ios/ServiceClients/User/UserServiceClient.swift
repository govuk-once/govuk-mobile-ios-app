import Foundation
import GovKit

typealias FetchUserInfoCompletion = (UserInfoResult) -> Void
typealias UserInfoResult = Result<UserInfoResponse, UserAPIError>

protocol UserServiceClientInterface {
    func fetchUserInfo(completion: @escaping FetchUserInfoCompletion)
}

enum UserAPIError: LocalizedError {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case authenticationError
}

struct UserServiceClient: UserServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface
    private let authenticationService: AuthenticationServiceInterface

    init(apiServiceClient: APIServiceClientInterface,
         authenticationService: AuthenticationServiceInterface) {
        self.apiServiceClient = apiServiceClient
        self.authenticationService = authenticationService
    }

    func fetchUserInfo(completion: @escaping FetchUserInfoCompletion) {
        let request = GOVRequest.getUserInfo(
            accessToken: authenticationService.accessToken
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                completion(mapResult(result))
            })
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, UserAPIError> {
        return result.mapError { error in
            let nsError = (error as NSError)
            if nsError.code == NSURLErrorNotConnectedToInternet {
                return UserAPIError.networkUnavailable
            } else {
                return (error as? UserAPIError) ?? UserAPIError.apiUnavailable
            }
        }.flatMap {
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(UserAPIError.decodingError)
            }
        }
    }
}
