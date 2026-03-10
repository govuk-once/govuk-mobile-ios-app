import Foundation
import GovKit

typealias LinkAccountResult = Result<Void, DVLAError>
typealias LinkAccountCompletion = (LinkAccountResult) -> Void

protocol DVLAServiceClientInterface {
    func linkAccount(linkId: String,
                     completion: @escaping (LinkAccountResult) -> Void)
}

struct DVLAServiceClient: DVLAServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface
    private let authenticationService: AuthenticationServiceInterface

    init(apiServiceClient: APIServiceClientInterface,
         authenticationService: AuthenticationServiceInterface) {
        self.apiServiceClient = apiServiceClient
        self.authenticationService = authenticationService
    }

    func linkAccount(linkId: String,
                     completion: @escaping (LinkAccountResult) -> Void) {
        let request = GOVRequest.linkAccount(
            linkId: linkId
        )
        apiServiceClient.send(request: request, completion: { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(mapError(error)))
            }
        })
    }

    private func mapError(_ error: Error) -> DVLAError {
        let nsError = (error as NSError)
        if nsError.code == NSURLErrorNotConnectedToInternet {
            return DVLAError.networkUnavailable
        } else {
            return (error as? DVLAError) ?? DVLAError.apiUnavailable
        }
    }
}
