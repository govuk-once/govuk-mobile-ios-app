import Foundation
import SwiftUI
import GovKit

final class DWPWidgetViewModel: ObservableObject {
    @Published var state: State = .loading
    private let analyticsService: AnalyticsServiceInterface
    init(analyticsService: AnalyticsServiceInterface) {
        self.analyticsService = analyticsService
    }

    enum State {
        case loading
        case unlinked(linkCard: ServiceAccountLinkCardViewModel)
    }

    func fetchDWPData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .unlinked(
                linkCard: self.linkCardViewModel
            )
        }
    }

    private var linkCardViewModel: ServiceAccountLinkCardViewModel {
        let linkCardTitle = String.dwp.localized("dwpAccountLinkCardTitle")
        return ServiceAccountLinkCardViewModel(
            title: linkCardTitle,
            subtitle: String.dwp.localized("dwpAccountLinkCardSubtitle"),
            action: { }
        )
    }
}
