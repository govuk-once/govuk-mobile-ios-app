import UIKit
import SwiftUI
import GovKit

final class TravelTopicWidgetCoordinator: BaseCoordinator,
                                          TopicWidgetProvider {
    private let userService: UserServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder
    private let widgetViewBuilder: WidgetViewBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let urlOpener: URLOpener

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         widgetViewBuilder: WidgetViewBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         urlOpener: URLOpener) {
        self.analyticsService = analyticsService
        self.configService = configService
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.widgetViewBuilder = widgetViewBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.urlOpener = urlOpener
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        /* do nothing */
    }

    func makeWidget(
        for topic: DisplayableTopic
    ) -> AnyView? {
        guard topic.ref == "travel-abroad",
              configService.isFeatureEnabled(key: .travelAlerts) else {
            return nil
        }
        let placeholder = HStack(alignment: .center) {
            Text("Placeholder Travel Alerts")
                .padding(.horizontal, 16)
            Spacer()
        }
        return AnyView(placeholder)
    }
}
