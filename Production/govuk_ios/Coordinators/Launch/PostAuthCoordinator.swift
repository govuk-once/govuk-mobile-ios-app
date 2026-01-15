import Foundation
import UIKit
import GOVKit

class PostAuthCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let completion: () -> Void
    private let remoteConfigService: RemoteConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    init(coordinatorBuilder: CoordinatorBuilder,
         analyticsService: AnalyticsServiceInterface,
         remoteConfigService: RemoteConfigServiceInterface,
         navigationController: UINavigationController,
         completion: @escaping () -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
        self.remoteConfigService = remoteConfigService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        startAnalyicsOnboardingCoordinator()
    }

    private func startAnalyicsOnboardingCoordinator() {
        let coordinator = coordinatorBuilder.analyticsConsent(
            navigationController: root,
            completion: { [weak self] in
                if self?.analyticsService.permissionState == .accepted {
                    self?.activateRemoteConfig()
                    // activate remote config after analytics consent to support a/b testing
                } else {
                    self?.startTopicOnboarding()
                }
            }
        )
        start(coordinator)
    }
    private func activateRemoteConfig() {
        Task {
            await remoteConfigService.activate()
            startTopicOnboarding()
        }
    }

    private func startTopicOnboarding() {
        let coordinator = coordinatorBuilder.topicOnboarding(
            navigationController: root,
            didDismissAction: { [weak self] in
                self?.startNotificationOnboardingCoordinator()
            }
        )
        start(coordinator)
    }

    private func startNotificationOnboardingCoordinator() {
        let coordinator = coordinatorBuilder.notificationOnboarding(
            navigationController: root,
            completion: { [weak self] in
                self?.completion()
            }
        )
        start(coordinator)
    }
}
