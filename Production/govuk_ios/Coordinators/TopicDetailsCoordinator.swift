import UIKit
import GovKit

final class TopicDetailsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let topicsService: TopicsServiceInterface
    private let activityService: ActivityServiceInterface
    private let configService: AppConfigServiceInterface
    private let userService: UserServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let topic: Topic

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         topicsService: TopicsServiceInterface,
         activityService: ActivityServiceInterface,
         configService: AppConfigServiceInterface,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         topic: Topic) {
        self.analyticsService = analyticsService
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.topicsService = topicsService
        self.activityService = activityService
        self.configService = configService
        self.userService = userService
        self.topic = topic
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        pushTopic(topic)
    }

    private var pushTopic: (DisplayableTopic) -> Void {
        return { [weak self] localTopic in
            guard let self = self
            else { return }
            let viewController = self.viewControllerBuilder.topicDetail(
                topic: localTopic,
                topicsService: self.topicsService,
                analyticsService: self.analyticsService,
                activityService: self.activityService,
                configService: self.configService,
                userService: self.userService,
                topicAction: self.presentTopicAction,
                subtopicAction: self.pushTopic,
                stepByStepAction: self.pushStepBySteps,
                openAction: { [weak self] url in
                    self?.presentWebView(url: url)
                },
                linkAccountAction: self.linkAccountAction
            )
            self.push(viewController, animated: true)
        }
    }

    private var pushStepBySteps: ([TopicDetailResponse.Content]) -> Void {
        return { [weak self] localContent in
            guard let self = self
            else { return }
            let viewController = self.viewControllerBuilder.stepByStep(
                content: localContent,
                analyticsService: self.analyticsService,
                activityService: self.activityService,
                selectedAction: { [weak self] content in
                    self?.presentWebView(url: content.url)
                }
            )
            self.push(viewController, animated: true)
        }
    }

    private var linkAccountAction: () -> Void {
        return { [weak self] in
            guard let self = self else { return }
            let navigationController = UINavigationController()
            navigationController.modalPresentationStyle = .fullScreen
            let coordinator = coordinatorBuilder.serviceAccountLink(
                navigationController: navigationController,
                accountType: .dvla, completion: { [weak self] hasLinkedAccount in
                    print("service account linking dismissed")
                    if hasLinkedAccount {
                        self?.startDvlaAccount(viewType: .drivingLicence)
                    }
                }
            )
            present(coordinator)
        }
    }

    private var presentTopicAction: (DisplayableTopic) -> Void {
        // DVLA account linking action hard coded for now
        return { [weak self] content in
            guard let self = self else { return }

            if content.ref == "dvla-unlink-account" {
                let navigationController = UINavigationController()
                navigationController.modalPresentationStyle = .fullScreen
                let coordinator = coordinatorBuilder.serviceAccountUnlink(
                    navigationController: navigationController,
                    accountType: .dvla, completion: {
                        print("service account unlinking dismissed")
                    }
                )
                present(coordinator)
            } else if content.ref == "dvla-view-licence" {
                startDvlaAccount(viewType: .drivingLicence)
            } else if content.ref == "dvla-view-driver-summary" {
                startDvlaAccount(viewType: .driverSummary)
            }
        }
    }

    private func startDvlaAccount(viewType: DVLAAccountViewType) {
        let coordinator = coordinatorBuilder.dvlaAccount(
            navigationController: root,
            viewType: viewType
        )
        start(coordinator)
    }

    private func presentWebView(url: URL) {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: true
        )
        start(coordinator, url: url)
    }
}
