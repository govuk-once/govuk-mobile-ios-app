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

    struct ItemViewModel: Identifiable, Hashable {
        let color: LocalWasteBinColor?
        let title: String
        let description: String?
        let accessibilityLabel: String
        let id: String

        init(color: LocalWasteBinColor?,
             title: String,
             description: String?) {
            self.color = color
            self.title = title
            self.description = description
            self.id = "\(color?.rawValue ?? "")!\(title)!\(description ?? "")"

            var accessibilityLabel = title
            if let colorAccessibility = color?.accessibilityLabel {
                accessibilityLabel += ", \(colorAccessibility)"
            }
            if let description {
                accessibilityLabel += ", \(description)"
            }
            self.accessibilityLabel = accessibilityLabel
        }
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
    private(set) var items: [ItemViewModel] = []

    let title: String = String.localWaste.localized(
        "localWasteTitle"
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

    private let service: LocalWasteServiceInterface

    private var initialBindTask: Task<Void, Never>?

    init(service: LocalWasteServiceInterface) {
        self.service = service
    }

    func initialBind() {
        guard viewState == .initial else { return }

        initialBindTask = Task {
            await load()
            initialBindTask = nil
        }
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
        } catch {
            viewState = .error
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let scheduleTodayOrLater = schedule.filter { $0.date >= today }
        let nextDate = scheduleTodayOrLater.min(by: {$0.date < $1.date})?.date
        let nextItems = scheduleTodayOrLater.filter { $0.date == nextDate }

        items = nextItems.map {
            .init(color: $0.color,
                  title: $0.name,
                  description: $0.content)
        }

        address = addressObj.addressFull

        if let nextDate {
            dueDate = dueDateLabel(from: nextDate)
        } else {
            dueDate = ""
        }

        viewState = .ready
    }

    private func formatDueDate(from date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return String.localWaste.localized("localWasteWidgetViewDueToday")
        }
        if calendar.isDateInTomorrow(date) {
            return String.localWaste.localized("localWasteWidgetViewDueTomorrow")
        }

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")

        return formatter.string(from: date)
    }

    private func dueDateLabel(from date: Date) -> String {
        let dueDateString = formatDueDate(from: date)

        let formatSting = String.localWaste.localized(
            "localWasteWidgetViewDueDateLabelFormat"
        )
        return String(format: formatSting, dueDateString)
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
