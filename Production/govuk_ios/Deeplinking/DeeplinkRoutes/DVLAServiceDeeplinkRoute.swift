import Foundation
import UIKit

import GovKit

struct DVLAServiceDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder
    private let analyticsService: AnalyticsServiceInterface

    init(
        coordinatorBuilder: CoordinatorBuilder,
        analyticsService: AnalyticsServiceInterface
    ) {
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
    }

    var pattern: URLPattern {
        "/callback/dvla/auth"
    }

    @MainActor
    func action(parent: BaseCoordinator,
                params: [String: String]) {
        parent.root.dismiss(animated: false)

        guard let token = params["token"] else {
            if params["failure"] == "true" {
                let error = DVLAAccountLinkingCallbackError.failure(
                    params["errorMessage"]
                )
                analyticsService.track(error: error)
            }
            return
        }

        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = coordinatorBuilder.serviceAccountRedirect(
            navigationController: navigationController,
            accountType: .dvla,
            token: token
        )
        parent.present(coordinator)
    }

    enum DVLAAccountLinkingCallbackError: LocalizedError {
        case failure(String?)

        var errorDescription: String? {
            switch self {
            case .failure(let message):
                return message ?? "DVLA account linking failed"
            }
        }
    }
}
