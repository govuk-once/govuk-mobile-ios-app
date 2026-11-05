import UIKit
import SwiftUI
import GovKit



final class BenefitWidgetCoordinator: BaseCoordinator {
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
         coordinatorBuilder: CoordinatorBuilder,
         widgetViewBuilder: WidgetViewBuilder,
         urlOpener: URLOpener) {
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
        guard topic.ref == "benefits",
              configService.isFeatureEnabled(key: .benefits) else {
            return nil
        }
        let actions = DVLAAccountWidgetActions(
            linkAction: startLinkAccount,
            vehicleDetailAction: { [weak self] vehicleID in
                self?.startVehicleDetail(vehicleID)
            },
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            vehicleCheckAction: { [weak self] in
                self?.startVehicleCheck()
            }
        )
        return widgetViewBuilder.dvlaAccountWidget(
            analyticsService: analyticsService,
            userService: userService,
            dvlaService: dvlaService,
            configService: configService,
            actions: actions
        )
    }

    private func startVehicleDetail(_ vehicleId: Int) {
        let coordinator = coordinatorBuilder.vehicleDetail(
            navigationController: root,
            vehicleId: vehicleId
        )
        start(coordinator)
    }

    private func startVehicleCheck() {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .overCurrentContext

        let coordinator = coordinatorBuilder.vehicleCheck(
            navigationController: navigationController
        )
        present(coordinator)
    }

    private func startLinkAccount() {
        let navigationController = BaseNavigationController()
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
}

