import Foundation
import GovKit

typealias FetchUserStateCompletion = (UserStateResult) -> Void
typealias UserStateResult = Result<UserState, UserStateError>
typealias NotificationsPreferenceResult = Result<NotificationsPreferenceResponse, UserStateError>

protocol UserServiceClientInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(accepted: Bool,
                                 completion: @escaping (NotificationsPreferenceResult) -> Void)
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

    func setNotificationsConsent(accepted: Bool,
                                 completion: @escaping (NotificationsPreferenceResult) -> Void) {
        let request = GOVRequest.setNotificationsConsent(
            accepted: accepted
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
            decoder.dateDecodingStrategy = .custom({ decoder in
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                guard let date = formatter.date(from: dateString) else {
                    throw UserStateError.decodingError
                }
                return date
            })
            do {
                let response = try decoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(UserStateError.decodingError)
            }
        }
    }
}
