import UIKit
import Foundation

class PreAuthCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let appLaunchService: AppLaunchServiceInterface
    private let completion: () -> Void

    init(coordinatorBuilder: CoordinatorBuilder,
         navigationController: UINavigationController,
         appLaunchService: AppLaunchServiceInterface,
         completion: @escaping () -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.appLaunchService = appLaunchService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        startJailbreakDetection(url: url)
    }

    private func startJailbreakDetection(url: URL?) {
        let coordinator = coordinatorBuilder.jailbreakDetector(
            navigationController: root,
            dismissAction: { [weak self] in
                self?.startLaunch(
                    url: url
                )
            }
        )
        start(coordinator)
    }

    private func startLaunch(url: URL?) {
        let coordinator = coordinatorBuilder.launch(
            navigationController: root,
            completion: { [weak self] response in
                self?.startNotificationConsentCheck(
                    url: url,
                    launchResponse: response
                )
            }
        )
        start(coordinator)
    }

    private func startNotificationConsentCheck(url: URL?,
                                               launchResponse: AppLaunchResponse) {
        let coordinator = coordinatorBuilder.notificationConsent(
            navigationController: root,
            consentResult: launchResponse.notificationConsentResult,
            completion: { [weak self] in
                self?.startAppForcedUpdate(
                    url: url,
                    launchResponse: launchResponse
                )
            }
        )
        start(coordinator)
    }

    private func startAppForcedUpdate(url: URL?,
                                      launchResponse: AppLaunchResponse) {
        let coordinator = coordinatorBuilder.appForcedUpdate(
            navigationController: root,
            launchResponse: launchResponse,
            dismissAction: { [weak self] in
                self?.startAppUnavailable(
                    url: url,
                    launchResponse: launchResponse
                )
            }
        )
        start(coordinator)
    }

    private func startAppUnavailable(url: URL?,
                                     launchResponse: AppLaunchResponse) {
        let error = launchResponse.configResult.getError()?.asAppUnavailableError()
        let coordinator = coordinatorBuilder.appUnavailable(
            navigationController: root,
            error: error,
            retryAction: { [weak self] completion in
                self?.appLaunchService.fetch { response in
                    completion(response.isAppAvailable)
                }
            },
            dismissAction: { [weak self] in
                self?.startAppRecommendUpdate(
                    url: url,
                    launchResponse: launchResponse
                )
            }
        )
        start(coordinator)
    }

    private func startAppRecommendUpdate(url: URL?,
                                         launchResponse: AppLaunchResponse) {
        let coordinator = coordinatorBuilder.appRecommendUpdate(
            navigationController: root,
            launchResponse: launchResponse,
            dismissAction: { [weak self] in
                self?.completion()
            }
        )
        start(coordinator)
    }
}
