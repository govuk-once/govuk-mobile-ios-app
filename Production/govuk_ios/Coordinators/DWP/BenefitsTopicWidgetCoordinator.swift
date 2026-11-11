import UIKit
import SwiftUI
import GovKit

final class BenefitsTopicWidgetCoordinator: BaseCoordinator,
                                           TopicWidgetProvider {
    private let widgetViewBuilder: WidgetViewBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         widgetViewBuilder: WidgetViewBuilder) {
        self.analyticsService = analyticsService
        self.configService = configService
        self.coordinatorBuilder = coordinatorBuilder
        self.widgetViewBuilder = widgetViewBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        /* do nothing */
    }

    func makeWidget(
        for topic: DisplayableTopic
    ) -> AnyView? {
        guard topic.ref == "benefits",
              configService.isFeatureEnabled(key: .dwp)
        else {
            return nil
        }
        return widgetViewBuilder.getDWPWidget(
            analyticsService: analyticsService
        )
    }
}
