import Foundation
import GovKit

// MARK: - Country list sheet
extension EditCountriesViewModel {
    func openCountryList() {
        analyticsService.track(
            event: AppEvent.buttonNavigation(
                text: followAnotherTitle,
                external: false,
                section: EditCountriesAnalyticsKeys.section
            )
        )
        isShowingList = true
    }

    @MainActor
    func countryListSheetDidDismiss() {
        countryListViewModel.sheetDidDismiss()
        didDismissList(forceRefresh: false)
    }
}
