import Foundation
import GovKitUI
import SwiftUI

@MainActor
final class LocalWasteWidgetViewModel: ObservableObject {
    enum ViewState: Hashable {
        case initial
        case loading
        case ready
        case error
    }

    @Published
    private(set) var viewState: ViewState = .initial

    @Published
    private(set) var address: String = "" {
        didSet {
            let format = String.localWaste.localized(
                "localWasteWidgetViewAddressAccessibilityLabelFormat"
            )
            addressAccessibilityLabel = String(format: format, address)
        }
    }

    @Published
    private(set) var addressAccessibilityLabel: String = ""

    @Published
    private(set) var dueDate: String = ""

    @Published
    private(set) var items: [LocalWasteScheduleItemViewModel] = []

    @Published
    private(set) var isScheduleAvailable: Bool = false

    let openEditViewAction: () -> Void

    let openScheduleViewAction: () -> Void

    let title: String = String.localWaste.localized(
        "localWasteTitle"
    )
    let editButton = String.common.localized(
        "editButtonTitle"
    )
    let editButtonAccessibilityLabel = String.localWaste.localized(
        "localWasteEditButtonAccessibilityLabel"
    )
    let loadingAccessibilityLabel: String = String.localWaste.localized(
        "localWasteWidgetViewLoadingAccessibilityLabel"
    )
    let dueTimeLabel: String = String.localWaste.localized(
        "localWasteWidgetViewDueTimeLabel"
    )
    let emptyLabel: String = String.localWaste.localized(
        "localWasteWidgetViewEmptyLabel"
    )
    let errorLabel: String = String.localWaste.localized(
        "localWasteWidgetViewErrorLabel"
    )
    let tryAgainButton: String = String.localWaste.localized(
        "localWasteWidgetViewTryAgainButton"
    )
    let scheduleButton = String.localWaste.localized(
        "localWasteWidgetViewScheduleButton"
    )

    private let service: LocalWasteServiceInterface

    private var initialBindTask: Task<Void, Never>?

    private var cachedSchedule: [LocalWasteBin]?

    init(service: LocalWasteServiceInterface,
         openEditViewAction: @escaping () -> Void,
         openScheduleViewAction: @escaping () -> Void) {
        self.service = service
        self.openEditViewAction = openEditViewAction
        self.openScheduleViewAction = openScheduleViewAction
    }

    func startLoadingIfViewStateInitial() {
        guard viewState == .initial else { return }
        viewState = .loading

        initialBindTask = Task {
            await load()
            initialBindTask = nil
        }
    }

    func resetViewState() {
        viewState = .initial
        address = ""
        addressAccessibilityLabel = ""
        dueDate = ""
        items = []
    }

    func load() async {
        viewState = .loading

        guard let addressObj = service.fetchAddress() else {
            viewState = .error
            return
        }

        let schedule: [LocalWasteBin]
        do {
            schedule = try await service.fetchSchedule(
                uprn: addressObj.uprn,
                localCustodianCode: addressObj.localCustodianCode)

            cachedSchedule = schedule
        } catch {
            viewState = .error
            return
        }

        let scheduleTodayOrLater = schedule.todayOrLater()
        let nextDate = scheduleTodayOrLater.minDate()
        let nextItems = scheduleTodayOrLater
            .filter { $0.date == nextDate }
            .sortedAscending()

        items = nextItems.toItemViewModels()

        isScheduleAvailable = scheduleTodayOrLater.count > nextItems.count

        address = addressObj.addressFull

        if let nextDate {
            dueDate = dueDateLabel(from: nextDate)
        } else {
            dueDate = ""
        }

        viewState = .ready
    }

    private func dueDateLabel(from date: Date) -> String {
        let dueDateString = date.localWasteFormattedCollectionDate()

        let formatSting = String.localWaste.localized(
            "localWasteWidgetViewDueDateLabelFormat"
        )
        return String(format: formatSting, dueDateString)
    }

    func onViewScheduleTapped() {
        guard let cachedSchedule = cachedSchedule else { return }
        service.pushScheduleCache(cachedSchedule)
        openScheduleViewAction()
    }
}

extension LocalWasteBinColor {
    var accessibilityLabel: String {
        switch self {
        case .black: return String.localWaste.localized(
            "localWasteColorAccessibilityBlack"
        )
        case .green: return String.localWaste.localized(
            "localWasteColorAccessibilityGreen"
        )
        case .red: return String.localWaste.localized(
            "localWasteColorAccessibilityRed"
        )
        case .blue: return String.localWaste.localized(
            "localWasteColorAccessibilityBlue"
        )
        case .brown: return String.localWaste.localized(
            "localWasteColorAccessibilityBrown"
        )
        case .yellow: return String.localWaste.localized(
            "localWasteColorAccessibilityYellow"
        )
        case .silver: return String.localWaste.localized(
            "localWasteColorAccessibilitySilver"
        )
        case .purple: return String.localWaste.localized(
            "localWasteColorAccessibilityPurple"
        )
        }
    }
}

extension Array where Element == LocalWasteBin {
    func todayOrLater() -> [LocalWasteBin] {
        let minDate = Calendar.current.startOfDay(for: Date())
        let maxDate = Calendar.current.date(byAdding: .day, value: 90, to: minDate)!
        return self.filter { $0.date >= minDate && $0.date <= maxDate }
    }
    func minDate() -> Date? {
        self.min(by: {$0.date < $1.date})?.date
    }
    func sortedAscending() -> [LocalWasteBin] {
        self.sorted(by: {
            if $0.date != $1.date {
                return $0.date < $1.date
            } else {
                return $0.name < $1.name
            }
        })
    }
    func toItemViewModels() -> [LocalWasteScheduleItemViewModel] {
        self.map {
            .init(color: $0.color,
                  title: $0.name,
                  description: $0.content)
        }
    }
}

private extension Date {
    func localWasteFormattedCollectionDate() -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return String.localWaste.localized("localWasteWidgetViewDueToday")
        }
        if calendar.isDateInTomorrow(self) {
            return String.localWaste.localized("localWasteWidgetViewDueTomorrow")
        }

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")

        return formatter.string(from: self)
    }
}
