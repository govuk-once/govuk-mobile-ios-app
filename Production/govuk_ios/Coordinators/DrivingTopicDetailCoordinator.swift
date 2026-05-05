import UIKit
import SwiftUI
import GovKit

final class DrivingTopicDetailCoordinator: TopicDetailsCoordinator {
    private let dvlaService: DVLAServiceInterface
    private let userService: UserServiceInterface
    private let widgetViewBuilder: WidgetViewBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         topicsService: TopicsServiceInterface,
         activityService: ActivityServiceInterface,
         configService: AppConfigServiceInterface,
         userService: UserServiceInterface,
         dvlaService: DVLAServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         widgetViewBuilder: WidgetViewBuilder,
         topic: Topic) {
        self.dvlaService = dvlaService
        self.analyticsService = analyticsService
        self.configService = configService
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.widgetViewBuilder = widgetViewBuilder
        super.init(
            navigationController: navigationController,
            analyticsService: analyticsService,
            topicsService: topicsService,
            activityService: activityService,
            coordinatorBuilder: coordinatorBuilder,
            viewControllerBuilder: viewControllerBuilder,
            topic: topic
        )
    }

    override func accountWidget(
        for topic: DisplayableTopic
    ) -> AnyView? {
        guard topic.ref == "driving-transport",
              configService.isFeatureEnabled(key: .dvla) else {
            return nil
        }
        return widgetViewBuilder.dvlaAccountWidget(
            analyticsService: analyticsService,
            userService: userService,
            dvlaService: dvlaService,
            linkAction: startLinkAccount,
            unlinkAction: startUnlinkAccount,
            viewLicenceAction: { [weak self] in
                self?.startDvlaAccount(viewType: .drivingLicence)
            },
            viewDriverSummaryAction: { [weak self] in
                self?.startDvlaAccount(viewType: .driverSummary)
            },
            viewCustomerSummaryAction: { [weak self] in
                self?.startDvlaAccount(viewType: .customerSummary)
            }
        )
    }

    private func startLinkAccount() {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = coordinatorBuilder.serviceAccountLink(
            navigationController: navigationController,
            accountType: .dvla, completion: { _ in
                print("service account linking dismissed")
            }
        )
        present(coordinator)
    }

    private func startUnlinkAccount() {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = coordinatorBuilder.serviceAccountUnlink(
            navigationController: navigationController,
            accountType: .dvla, completion: {
                print("service account unlinking dismissed")
            }
        )
        present(coordinator)
    }

    private func startDvlaAccount(viewType: DVLAAccountViewType) {
        let coordinator = coordinatorBuilder.dvlaAccount(
            navigationController: root,
            viewType: viewType
        )
        start(coordinator)
    }
}
