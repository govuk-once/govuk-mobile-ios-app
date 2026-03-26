import Foundation
import GovKitUI
import GovKit
import SwiftUI

@MainActor
class LocalWasteScheduleViewModel: ObservableObject {
    let dismissAction: () -> Void

    let address: String

    let cancelButton: String = String.common.localized(
        "cancel"
    )
    let viewTitle: String =  String.localWaste.localized(
        "localWasteScheduleViewTitle"
    )
    let viewSubtitle: String =  String.localWaste.localized(
        "localWasteScheduleViewSubtitle"
    )

    private let service: LocalWasteServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    let items: [LocalWasteScheduleGroupViewModel]

    init(service: LocalWasteServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         dismissAction: @escaping () -> Void) {
        self.service = service
        self.analyticsService = analyticsService
        self.dismissAction = dismissAction

        self.address = service.fetchAddress()?.addressFull ?? ""
        let schedule = service.popScheduleCache() ?? []
        self.items = schedule.toSortedGroupedItemViewModels()
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}

extension Array where Element == LocalWasteBin {
    func toSortedGroupedItemViewModels() -> [LocalWasteScheduleGroupViewModel] {
        let grouped = Dictionary(grouping: self.todayOrLater(), by: \.date)

        return grouped
            .sorted { $0.key < $1.key }
            .map { date, items in
                LocalWasteScheduleGroupViewModel(
                    dateDisplay: date.localWasteFormattedCollectionDate(),
                    items: items
                        .sortedAscending()
                        .toItemViewModels()
                )
            }
    }
}

private extension Date {
    func localWasteFormattedCollectionDate() -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return String.localWaste.localized("localWasteScheduleViewToday")
        }
        if calendar.isDateInTomorrow(self) {
            return String.localWaste.localized("localWasteScheduleViewTomorrow")
        }

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")

        return formatter.string(from: self)
    }
}
