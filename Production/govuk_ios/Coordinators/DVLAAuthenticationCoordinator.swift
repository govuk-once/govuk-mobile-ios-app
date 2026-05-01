import Foundation
import GovKit
import UIKit

enum DVLAAuthError: Error {
    case userCancelled
    case tokenNotFound
    case linkIdNotFound
    case invalidCallbackUrl
    case unknown
}

final class DVLAAuthenticationCoordinator: BaseCoordinator {
    private let authenticationService: DVLAAuthenticationServiceInterface
    private let completion: (String) -> Void
    private let errorAction: (DVLAAuthError) -> Void

    override func start(url: URL?) {
        authenticate()
    }

    init(navigationController: UINavigationController,
         authenticationService: DVLAAuthenticationServiceInterface,
         completion: @escaping (String) -> Void,
         errorAction: @escaping (DVLAAuthError) -> Void) {
        self.authenticationService = authenticationService
        self.completion = completion
        self.errorAction = errorAction
        super.init(navigationController: navigationController)
    }

    private func authenticate() {
        Task {
            guard let window = root.view.window else {
                return
            }
            let result = await authenticationService.authenticate(window: window)
            switch result {
            case .success(let linkId):
                completion(linkId)
            case .failure(let error):
                errorAction(error)
            }
        }
    }
}
