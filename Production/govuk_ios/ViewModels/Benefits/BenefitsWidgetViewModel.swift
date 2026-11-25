import Foundation
import SwiftUI
import GovKit

final class BenefitsWidgetViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    private let analyticsService: AnalyticsServiceInterface
    let linkAction: () -> Void
    init(analyticsService: AnalyticsServiceInterface,
         state: State = .loading,
         linkAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.state = state
        self.linkAction = linkAction
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
            action: { [weak self ] in
                self?.linkAction()
            }
        )
    }
}
