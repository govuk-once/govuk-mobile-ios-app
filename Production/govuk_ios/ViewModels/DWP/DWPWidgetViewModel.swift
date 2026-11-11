import Foundation
import SwiftUI
import GovKit

final class DWPWidgetViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    private let analyticsService: AnalyticsServiceInterface
    init(analyticsService: AnalyticsServiceInterface,
         state: State = .loading) {
        self.analyticsService = analyticsService
        self.state = state
    }

    enum State {
        case loading
        case unlinked(linkCard: ServiceAccountLinkCardViewModel)
    }

    @MainActor
    func fetchDWPData() {
        state = .unlinked(
            linkCard: self.linkCardViewModel
        )
    }

    private var linkCardViewModel: ServiceAccountLinkCardViewModel {
        let linkCardTitle = String.dwp.localized("dwpAccountLinkCardTitle")
        return ServiceAccountLinkCardViewModel(
            title: linkCardTitle,
            subtitle: String.dwp.localized("dwpAccountLinkCardSubtitle"),
            action: { /* no-op */ }
        )
    }
}
