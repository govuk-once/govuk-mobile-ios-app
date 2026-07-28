import Foundation
import UIKit
import GovKit

final class VehicleDetailCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let configService: AppConfigServiceInterface
    private let userService: UserServiceInterface
    private let urlOpener: URLOpener
    private let notificationCenter: NotificationCenter
    private let vehicleId: Int

    private var linkedAccountsObserverToken: Any?

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         configService: AppConfigServiceInterface,
         userService: UserServiceInterface,
         urlOpener: URLOpener,
         notificationCenter: NotificationCenter,
         vehicleId: Int) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.userService = userService
        self.urlOpener = urlOpener
        self.notificationCenter = notificationCenter
        self.vehicleId = vehicleId
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.vehicleDetail(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            vehicleId: vehicleId
        )
        observeLinkedAccountChanges()
        push(viewController)
    }

    private func observeLinkedAccountChanges() {
        linkedAccountsObserverToken = notificationCenter.addObserver(
            forName: .linkedAccountsDidChange,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                if self?.userService.linkedAccounts?.contains(.dvla) == false {
                    self?.root.popViewController(animated: true)
                }
            }
        )
    }
}
