import Foundation
import UIKit
import CoreData
import GovKit

final class TravelAlertsWidgetViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    // Drives .sheet(isPresented:) in the widget view
    @Published var isShowingList = false
    @Published private(set) var viewState: ViewState = .loading

    private let travelService: TravelServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let linkAction: () -> Void
    private let dismissAction: () -> Void

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        linkAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.linkAction = linkAction
        self.dismissAction = dismissAction
    }

    @MainActor
    func viewDidAppear() async {
        await fetchCountryList()
    }

    @MainActor
    private func fetchCountryList() async {
        viewState = .loading

        travelService.getGroups(forceRefresh: false) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.viewState = .loaded
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }

    func openCountryList() {
        let event = AppEvent.widgetNavigation(
            text: "Add your countries",
            external: false,
            params: ["section": "Travel Abroad Notifications"]
        )
        analyticsService.track(event: event)
        isShowingList = true
    }

    func didDismissList() {
        isShowingList = false
        dismissAction()
    }
}
