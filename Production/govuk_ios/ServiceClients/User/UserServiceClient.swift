import Foundation
import GovKit

typealias FetchUserStateCompletion = (UserStateResult) -> Void
typealias UserStateResult = Result<UserState, UserStateError>
typealias NotificationsPreferenceResult = Result<UserNotificationsPreferences, UserStateError>
typealias LinkAccountResult = Result<Void, UserStateError>
typealias LinkAccountCompletion = (LinkAccountResult) -> Void
typealias UnlinkAccountResult = Result<Void, UserStateError>
typealias UnlinkAccountCompletion = (UnlinkAccountResult) -> Void

protocol UserServiceClientInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus,
                                 completion: @escaping (NotificationsPreferenceResult) -> Void)
    func linkAccount(serviceName: String,
                     linkId: String,
                     completion: @escaping (LinkAccountResult) -> Void)
    func unlinkAccount(serviceName: String,
                       completion: @escaping (UnlinkAccountCompletion))
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
        let request = GOVRequest.userState
        apiServiceClient.send(
            request: request,
            completion: { result in
                completion(mapResult(result))
            })
    }

    func setNotificationsConsent(_ consentStatus: ConsentStatus,
                                 completion: @escaping (NotificationsPreferenceResult) -> Void) {
        let request = GOVRequest.setNotificationsConsent(
            consentStatus: consentStatus
        )
        apiServiceClient.send(
            request: request) { result in
                completion(mapResult(result))
            }
    }

    func linkAccount(serviceName: String,
                     linkId: String,
                     completion: @escaping (LinkAccountCompletion)) {
        let request = GOVRequest.linkAccount(
            serviceName: serviceName,
            linkId: linkId
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(mapError(error)))
                }
            }
        )
    }

    func unlinkAccount(serviceName: String,
                       completion: @escaping (UnlinkAccountCompletion)) {
        let request = GOVRequest.unlinkAccount(
            serviceName: serviceName
        )
        apiServiceClient.send(
            request: request,
            completion: { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(mapError(error)))
                }
            }
        )
    }

    private func mapError(_ error: Error) -> UserStateError {
        let nsError = (error as NSError)
        if nsError.code == NSURLErrorNotConnectedToInternet {
            return UserStateError.networkUnavailable
        } else {
            return (error as? UserStateError) ?? UserStateError.apiUnavailable
        }
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, UserStateError> {
        return result.mapError {
            mapError($0)
        }.flatMap {
            do {
                let response = try JSONDecoder().decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(UserStateError.decodingError)
            }
        }
    }
}
