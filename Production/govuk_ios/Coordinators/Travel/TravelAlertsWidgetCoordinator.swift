import UIKit
import SwiftUI
import GovKit

final class TravelAlertsWidgetCoordinator: BaseCoordinator,
                                          TopicWidgetProvider {
    private let viewControllerBuilder: ViewControllerBuilder
    private let widgetViewBuilder: WidgetViewBuilder
    private let travelService: TravelServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let urlOpener: URLOpener

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         travelService: TravelServiceInterface,
         configService: AppConfigServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         widgetViewBuilder: WidgetViewBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         urlOpener: URLOpener) {
        self.analyticsService = analyticsService
        self.travelService = travelService
        self.configService = configService
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
        return widgetViewBuilder.followCountryWidget(
            analyticsService: analyticsService,
            travelService: travelService,
            linkAction: { [weak self] in
                self?.startCountrySelection()
            },
            dismissAction: { [weak self] in
                self?.root.viewWillReAppear()
            }
        )
    }

    private func startCountrySelection() {
        let navigationController = BaseNavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = coordinatorBuilder.followCountry(
            navigationController: navigationController,
            completion: { _ in
                print("select countries dismissed")
            }
        )
        present(coordinator)
    }
}
