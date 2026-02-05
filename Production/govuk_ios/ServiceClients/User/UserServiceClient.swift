import Foundation
import GovKit

typealias FetchUserStateCompletion = (UserStateResult) -> Void
typealias UserStateResult = Result<UserState, UserStateError>
typealias UserPreferencesResult = Result<UserPreferencesResponse, UserStateError>

protocol UserServiceClientInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(accepted: Bool,
                                 completion: @escaping (UserPreferencesResult) -> Void)
}

struct UserServiceClient: UserServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface
    private let authenticationService: AuthenticationServiceInterface

    init(apiServiceClient: APIServiceClientInterface,
         authenticationService: AuthenticationServiceInterface) {
        self.apiServiceClient = apiServiceClient
        self.authenticationService = authenticationService
    }

    func fetchUserState(completion: @escaping FetchUserStateCompletion) {
        let request = GOVRequest.getUserState(
            accessToken: authenticationService.accessToken
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                completion(mapResult(result))
            })
    }

    func setNotificationsConsent(accepted: Bool,
                                 completion: @escaping (UserPreferencesResult) -> Void) {
        let request = GOVRequest.setNotificationsConsent(
            accepted: accepted,
            accessToken: authenticationService.accessToken
        )
        apiServiceClient.send(
            request: request) { result in
                completion(mapResult(result))
            }
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, UserStateError> {
        return result.mapError { error in
            let nsError = (error as NSError)
            if nsError.code == NSURLErrorNotConnectedToInternet {
                return UserStateError.networkUnavailable
            } else {
                return (error as? UserStateError) ?? UserStateError.apiUnavailable
            }
        }.flatMap {
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(UserStateError.decodingError)
            }
        }
    }
}
