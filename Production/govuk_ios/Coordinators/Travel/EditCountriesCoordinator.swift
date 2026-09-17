import UIKit
import GovKit

final class EditCountriesCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let travelService: TravelServiceInterface
    private let completion: () -> Void

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         travelService: TravelServiceInterface,
         completion: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.travelService = travelService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        showEditCountries()
    }

    private func showEditCountries() {
        let viewController = viewControllerBuilder.editCountries(
            travelService: travelService,
            analyticsService: analyticsService,
        )
        set(viewController)
    }
}
