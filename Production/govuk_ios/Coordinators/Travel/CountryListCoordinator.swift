import UIKit
import GovKit
import AuthenticationServices

final class CountryListCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let travelService: TravelServiceInterface
    private let notificationService: NotificationServiceInterface
    private let userService: UserServiceInterface
    private let urlOpener: URLOpener
    private let completion: (Bool) -> Void

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         travelService: TravelServiceInterface,
         notificationService: NotificationServiceInterface,
         userService: UserServiceInterface,
         urlOpener: URLOpener,
         completion: @escaping (Bool) -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.travelService = travelService
        self.notificationService = notificationService
        self.userService = userService
        self.urlOpener = urlOpener
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        showCountryList()
    }

    private func showCountryList() {
        let viewController = viewControllerBuilder.countryList(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            dismissAction: { _ in self.dismissModal() },
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            }
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }

    private func openPrivacy() {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: Constants.API.privacyPolicyUrl,
            fullScreen: false
        )
        start(coordinator)
    }
}
