import Foundation
import UIKit
import GovKit

// KK Stuff
// experimental: generic Coordinators...
/// a Coordinator that by default pushes onto the root navcon and can inject `specificData: T`
/// into any ViewControllers the Coordinator creates
class PushOnRootNavCoordinator<T>: BaseCoordinator {
    let viewControllerBuilder: DVLAViewControllerBuilding
    let analyticsService: AnalyticsServiceInterface
    let dvlaService: DVLAServiceInterface
    let configService: AppConfigServiceInterface
    let userService: UserServiceInterface
    let urlOpener: URLOpener
    let notificationCenter: NotificationCenter
    let specificData: T

    init(
        navigationController: UINavigationController,
        viewControllerBuilder: DVLAViewControllerBuilding,
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        userService: UserServiceInterface,
        urlOpener: URLOpener,
        notificationCenter: NotificationCenter,
        specificData: T
    ) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.userService = userService
        self.urlOpener = urlOpener
        self.notificationCenter = notificationCenter
        self.specificData = specificData
        super.init(navigationController: navigationController)
    }
}

// KK Stuff
// experimental: generic Coordinators...
// Convenience for any coordinator carrying no payload
extension PushOnRootNavCoordinator where T == Void {
    convenience init(
        navigationController: UINavigationController,
        viewControllerBuilder: DVLAViewControllerBuilding,
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        userService: UserServiceInterface,
        urlOpener: URLOpener,
        notificationCenter: NotificationCenter
    ) {
        self.init(
            navigationController: navigationController,
            viewControllerBuilder: viewControllerBuilder,
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            userService: userService,
            urlOpener: urlOpener,
            notificationCenter: notificationCenter,
            specificData: ()
        )
    }
}

// KK Stuff
// experimental: generic Coordinators...
// An instance of a generic coordinator that handles `EntitlementInfo`
final class CategoriesListWithDataCoordinator: PushOnRootNavCoordinator<EntitlementInfo> {
    private var linkedAccountsObserverToken: Any?

    override func start(url: URL?) {
//        let viewController = viewControllerBuilder.vehicleDetail(
//            analyticsService: analyticsService,
//            dvlaService: dvlaService,
//            configService: configService,
//            openURLAction: { [weak self] url in
//                self?.urlOpener.openIfPossible(url)
//            },
//            vehicleId: vehicleId
//        )
        let viewController = UIViewController()
        viewController.view.backgroundColor = .blue
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

final class CategoriesListCoordinator: PushOnRootNavCoordinator<Void> {
    private var linkedAccountsObserverToken: Any?

    override func start(url: URL?) {
//        let viewController = viewControllerBuilder.vehicleDetail(
//            analyticsService: analyticsService,
//            dvlaService: dvlaService,
//            configService: configService,
//            openURLAction: { [weak self] url in
//                self?.urlOpener.openIfPossible(url)
//            },
//            vehicleId: vehicleId
//        )
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
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
