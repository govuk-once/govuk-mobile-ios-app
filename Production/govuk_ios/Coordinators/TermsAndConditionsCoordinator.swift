import SwiftUI
import GovKit

final class TermsAndConditionsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userDefaultsService: UserDefaultsServiceInterface
    private let appConfigService: AppConfigServiceInterface
    private let completion: () -> Void

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         userDefaultsService: UserDefaultsServiceInterface,
         appConfigService: AppConfigServiceInterface,
         completion: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.appConfigService = appConfigService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard let acceptanceDate = userDefaultsService.value(
            forKey: .termsAndConditionsAcceptanceDate
        ) as? Date,
              acceptanceDate > appConfigService.termsAndConditions?.lastUpdated ?? .now  else {
            completion()
            return
        }
        completion()
    }
}
