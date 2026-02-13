import SwiftUI
import GovKit

final class TermsAndConditionsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let termsAndConditionsService: TermsAndConditionsServiceInterface
    private let completion: () -> Void

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         termsAndConditionsService: TermsAndConditionsServiceInterface,
         completion: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.termsAndConditionsService = termsAndConditionsService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard !termsAndConditionsService.termsAcceptanceIsValid else {
            completion()
            return
        }
        completion()
    }
}
