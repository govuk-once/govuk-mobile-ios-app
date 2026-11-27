import Combine
import Foundation
import GovKit

// MARK: - Analytics
extension CountryListViewModel {
    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func trackSearchInput(text: String) {
        let searchEvent = AppEvent.searchTerm(
            term: Redactor.pii.redact(text),
            type: .typed,
            section: CountryListAnalyticsKeys.searchSection
        )
        analyticsService.track(event: searchEvent)
    }

    func trackClose() {
        let closeEvent = AppEvent.buttonNavigation(
            text: CountryListAnalyticsKeys.closeText,
            external: false,
            section: CountryListAnalyticsKeys.section
        )
        analyticsService.track(event: closeEvent)
    }

    func trackToggleFunction(countryName: String) {
        let toggleEvent = AppEvent.toggleAction(
            text: countryName,
            section: CountryListAnalyticsKeys.section,
            action: "Add"
        )
        analyticsService.track(event: toggleEvent)
    }

    /// Filtering happens on every keystroke, so wait until the user stops typing
    /// before recording a search that matched no countries.
    func trackSearchesWithNoResults<S: Scheduler>(scheduler: S) -> AnyCancellable {
        $searchText
            .debounce(
                for: .milliseconds(Self.noResultsSearchDebounceMilliseconds),
                scheduler: scheduler
            )
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .sink { [weak self] query in
                self?.trackSearchWithNoResultsIfNeeded(query: query)
            }
    }

    private func trackSearchWithNoResultsIfNeeded(query: String) {
        guard !query.isEmpty,
              case .empty = viewState
        else { return }
        let searchEvent = AppEvent.searchTerm(
            term: Redactor.pii.redact(query),
            type: .typed,
            section: CountryListAnalyticsKeys.searchSection,
            extraParams: ["results": 0]
        )
        analyticsService.track(event: searchEvent)
    }
}
