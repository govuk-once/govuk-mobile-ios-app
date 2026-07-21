import UIKit
import SwiftUI
import GovKit

protocol TopicWidgetProvider {
    func makeWidget(for topic: DisplayableTopic) -> AnyView?
}

final class DrivingTopicWidgetCoordinator: BaseCoordinator,
                                           TopicWidgetProvider {
    private let dvlaService: DVLAServiceInterface
    private let userService: UserServiceInterface
    private let widgetViewBuilder: WidgetViewBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let urlOpener: URLOpener

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         userService: UserServiceInterface,
         dvlaService: DVLAServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         widgetViewBuilder: WidgetViewBuilder,
         urlOpener: URLOpener) {
        self.dvlaService = dvlaService
        self.analyticsService = analyticsService
        self.configService = configService
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.widgetViewBuilder = widgetViewBuilder
        self.urlOpener = urlOpener
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        /* do nothing */
    }

    func makeWidget(
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
            configService: configService,
            linkAction: startLinkAccount,
            vehicleDetailAction: { [weak self] vehicleID in
                self?.startVehicleDetail(vehicleID)
            },
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            }
        )
    }

    private func startVehicleDetail(_ vehicleId: Int) {
        let coordinator = coordinatorBuilder.vehicleDetail(
            navigationController: root,
            vehicleId: vehicleId
        )
        start(coordinator)
    }

    private func startLinkAccount() {
        let navigationController = BaseNavigationController(
            statusBarStyle: .lightContent
        )
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = coordinatorBuilder.serviceAccountLink(
            navigationController: navigationController,
            accountType: .dvla,
            completion: { _ in
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
            accountType: .dvla,
            completion: {
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
