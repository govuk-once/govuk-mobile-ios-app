import UIKit
import SwiftUI
import GovKit

final class BenefitsTopicWidgetCoordinator: BaseCoordinator,
                                           TopicWidgetProvider {
    private let widgetViewBuilder: WidgetViewBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         widgetViewBuilder: WidgetViewBuilder,
         viewControllerBuilder: ViewControllerBuilder) {
        self.analyticsService = analyticsService
        self.configService = configService
        self.coordinatorBuilder = coordinatorBuilder
        self.widgetViewBuilder = widgetViewBuilder
        self.viewControllerBuilder = viewControllerBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        root.navigationBar.prefersLargeTitles = true
        root.navigationItem.backButtonDisplayMode = .minimal
        let coordinator = coordinatorBuilder.benefitsContainer(
            navigationController: root,
            viewControllerBuilder: viewControllerBuilder,
            analyticsService: analyticsService,
            configService: configService
        )
        start(coordinator)
    }

    func makeWidget(
        for topic: DisplayableTopic
    ) -> AnyView? {
        guard topic.ref == "benefits",
              configService.isFeatureEnabled(key: .dwp)
        else {
            return nil
        }
        return widgetViewBuilder.makeBenefitsWidget(
            analyticsService: analyticsService,
            linkAction: { [weak self] in
                self?.start()
            }
        )
    }
}
