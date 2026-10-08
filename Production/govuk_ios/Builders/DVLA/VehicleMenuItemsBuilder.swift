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
        let canCancelTax = (taxStatus == .taxed) && !isSorn
        return [
            isSorn ? sornRulesItem : nil,
            soldVehicleItem,
            !isSorn ? makeSornItem : nil,
            getLogbookItem,
            changeLogbookAddressItem,
            canCancelTax ? cancelTaxItem : nil,
        ].compactMap { $0 }
    }

    private var sornRulesItem: DvlaMenuItemViewModel {
        let url = urls?.sornRules ?? Constants.API.defaultDvlaSornRulesUrl
        return DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuSornRulesTitle),
            accessibilityLabel: nil,
            openURLAction: { text in openAndTrack(url, buttonTitle: text) }
        )
    }

    private var soldVehicleItem: DvlaMenuItemViewModel {
        let url = urls?.soldVehicle ?? Constants.API.defaultDvlaSoldVehicleUrl
        return DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            accessibilityLabel: String(
                localized: .DVLA.vehicleMenuSoldVehicleAccessibilityLabelTitle
            ),
            openURLAction: { text in openAndTrack(url, buttonTitle: text) }
        )
    }

    private var makeSornItem: DvlaMenuItemViewModel {
        let url = urls?.makeSorn ?? Constants.API.defaultDvlaMakeSornUrl
        return DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuMakeSornTitle),
            accessibilityLabel: String(
                localized: .DVLA.vehicleMenuMakeSornAccessibilityLabelTitle
            ),
            openURLAction: { text in openAndTrack(url, buttonTitle: text) }
        )
    }

    private var getLogbookItem: DvlaMenuItemViewModel {
        let url = urls?.getLogbook ?? Constants.API.defaultDvlaGetLogbookUrl
        return DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            accessibilityLabel: nil,
            openURLAction: { text in openAndTrack(url, buttonTitle: text) }
        )
    }

    private var changeLogbookAddressItem: DvlaMenuItemViewModel {
        let url = urls?.changeLogbookAddress ?? Constants.API.defaultDvlaChangeLogbookAddressUrl
        return DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
            accessibilityLabel: nil,
            openURLAction: { text in openAndTrack(url, buttonTitle: text) }
        )
    }

    private var cancelTaxItem: DvlaMenuItemViewModel {
        let url = urls?.cancelTax ?? Constants.API.defaultDvlaCancelTaxUrl
        return DvlaMenuItemViewModel(
            title: String(localized: .DVLA.vehicleMenuCancelTaxTitle),
            accessibilityLabel: String(
                localized: .DVLA.vehicleMenuCancelTaxAccessibilityLabelTitle
            ),
            openURLAction: { text in openAndTrack(url, buttonTitle: text) }
        )
    }

    private func openAndTrack(_ url: URL, buttonTitle: String) {
        openURLAction(url)
        trackUrlOpenEvent(url: url, text: buttonTitle)
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
