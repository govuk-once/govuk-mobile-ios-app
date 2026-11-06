import Foundation
import SwiftUI
import GovKit

final class BenefitsWidgetViewModel: ObservableObject {
    @Published var state: State = .loading
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    init(analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface) {
        self.analyticsService = analyticsService
        self.configService = configService
    }

    enum State {
        case loading
        case unlinked(linkCard: ServiceAccountLinkCardViewModel)
    }

    func fetchedBenefitsData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .unlinked(
                linkCard: self.linkCardViewModel
            )
        }
    }

    private func trackLinkAccountNavigationEvent(title: String) {
        let event = AppEvent.linkServiceAccountNavigation(
            title: title
        )
        analyticsService.track(event: event)
    }

    private var linkCardViewModel: ServiceAccountLinkCardViewModel {
        let linkCardTitle = String.dvla.localized("dvlaAccountLinkCardTitle")
        return ServiceAccountLinkCardViewModel(
            title: linkCardTitle,
            subtitle: String.dvla.localized("dvlaAccountLinkCardSubtitle"),
            action: { [weak self] in
                self?.trackLinkAccountNavigationEvent(
                    title: linkCardTitle
                )
            }
        )
    }
}
