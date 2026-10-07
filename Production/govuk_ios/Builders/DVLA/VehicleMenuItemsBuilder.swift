import Foundation
import GovKit

/// Builds the context-sensitive menu items shown on vehicle detail
/// and summary screens, varying by SORN and tax status.
struct VehicleMenuItemsBuilder {
    private let urls: DvlaURLs?
    private let analyticsService: AnalyticsServiceInterface
    private let openURLAction: (URL) -> Void

    init(
        urls: DvlaURLs?,
        analyticsService: AnalyticsServiceInterface,
        openURLAction: @escaping (URL) -> Void
    ) {
        self.urls = urls
        self.analyticsService = analyticsService
        self.openURLAction = openURLAction
    }

    func makeMenuItems(
        sornStart: Date?,
        taxStatus: TaxStatus?
    ) -> [DvlaMenuItemViewModel] {
        let isSorn = sornStart != nil
        return [
            isSorn ? sornRulesItem : nil,
            soldVehicleItem,
            !isSorn ? makeSornItem : nil,
            getLogbookItem,
            changeLogbookAddressItem,
            taxStatus == .taxed ? cancelTaxItem : nil,
        ].compactMap { $0 }
    }

    private var sornRulesItem: DvlaMenuItemViewModel {
        DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuSornRulesTitle),
            accessibilityLabel: nil,
            openURLAction: { text in openSornRulesURL(text) }
        )
    }

    private var soldVehicleItem: DvlaMenuItemViewModel {
        DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            accessibilityLabel: String(
                localized: .DVLA.vehicleMenuSoldVehicleAccessibilityLabelTitle
            ),
            openURLAction: { text in openSoldVehicleURL(text) }
        )
    }

    private var makeSornItem: DvlaMenuItemViewModel {
        DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuMakeSornTitle),
            accessibilityLabel: String(
                localized: .DVLA.vehicleMenuMakeSornAccessibilityLabelTitle
            ),
            openURLAction: { text in openMakeSornURL(text) }
        )
    }

    private var getLogbookItem: DvlaMenuItemViewModel {
        DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            accessibilityLabel: nil,
            openURLAction: { text in openGetLogbookURL(text) }
        )
    }

    private var changeLogbookAddressItem: DvlaMenuItemViewModel {
        DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
            accessibilityLabel: nil,
            openURLAction: { text in openChangeLogbookAddressURL(text) }
        )
    }

    private var cancelTaxItem: DvlaMenuItemViewModel {
        DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuCancelTaxTitle),
            accessibilityLabel: String(
                localized: .DVLA.vehicleMenuCancelTaxAccessibilityLabelTitle
            ),
            openURLAction: { text in openCancelTaxURL(text) }
        )
    }

    private func openSornRulesURL(_ text: String) {
        let url = urls?.sornRules ??
        Constants.API.defaultDvlaSornRulesUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openSoldVehicleURL(_ text: String) {
        let url = urls?.soldVehicle ??
        Constants.API.defaultDvlaSoldVehicleUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openMakeSornURL(_ text: String) {
        let url = urls?.makeSorn ??
        Constants.API.defaultDvlaMakeSornUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openGetLogbookURL(_ text: String) {
        let url = urls?.getLogbook ??
        Constants.API.defaultDvlaGetLogbookUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openChangeLogbookAddressURL(_ text: String) {
        let url = urls?.changeLogbookAddress ??
        Constants.API.defaultDvlaChangeLogbookAddressUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openCancelTaxURL(_ text: String) {
        let url = urls?.cancelTax ??
        Constants.API.defaultDvlaCancelTaxUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openMenuURLAction(url: URL, text: String) {
        openURLAction(url)
        trackUrlOpenEvent(url: url, text: text)
    }

    private func trackUrlOpenEvent(url: URL, text: String) {
        let event = AppEvent.buttonNavigation(
            text: text,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }
}
