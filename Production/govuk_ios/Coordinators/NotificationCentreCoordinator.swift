import UIKit
import GovKit

class NotificationCentreCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let notificationCentreService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let urlOpener: URLOpener

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         notificationCentreService: NotificationCentreServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         urlOpener: URLOpener) {
        self.viewControllerBuilder = viewControllerBuilder
        self.notificationCentreService = notificationCentreService
        self.analyticsService = analyticsService
        self.coordinatorBuilder = coordinatorBuilder
        self.urlOpener = urlOpener
        super.init(navigationController: navigationController)
    }

    override func start(url _: URL?) {
        let viewController = viewControllerBuilder
            .notificationCentre(
                showNotificationAction: { [weak self] notification in
                    self?.showDetail(for: notification)
                },
                notificationService: notificationCentreService,
                analyticsService: analyticsService)

        self.push(viewController, animated: true)
    }

    open func showDetail(for notificationId: String) {
        let viewController = viewControllerBuilder
            .notificationCentreDetail(
                notificationId: notificationId,
                notificationService: notificationCentreService,
                analyticsService: analyticsService,
                actions: .init(
                    showUrlAction: { [weak self] url in
                        guard let self else { return }
                        presentWebView(url: url)
                    },
                    onUnreadAction: {
                        self.root.popViewController(animated: true)
                    },
                    onDeleteAction: {
                        self.root.popViewController(animated: true)
                    }
                )
            )
        self.push(viewController, animated: true)
    }

    private func presentWebView(url: URL) {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: false
        )
        start(coordinator, url: url)
    }
}
