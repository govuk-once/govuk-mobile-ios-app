import Foundation
import UIKit
import GovKit

class PostAuthCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let completion: () -> Void
    private let remoteConfigService: RemoteConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let notificationService: NotificationServiceInterface

    init(coordinatorBuilder: CoordinatorBuilder,
         analyticsService: AnalyticsServiceInterface,
         notificationService: NotificationServiceInterface,
         remoteConfigService: RemoteConfigServiceInterface,
         navigationController: UINavigationController,
         completion: @escaping () -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
        self.notificationService = notificationService
        self.remoteConfigService = remoteConfigService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        startNotificationConsentCheck()
    }

    private func startNotificationConsentCheck() {
        Task {
            let consentAlignmentResult = await notificationService.fetchConsentAlignment()
            let coordinator = coordinatorBuilder.notificationConsent(
                navigationController: root,
                consentResult: consentAlignmentResult,
                completion: { [weak self] in
                    self?.startAnalyicsOnboardingCoordinator()
                }
            )
            start(coordinator)
        }
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
