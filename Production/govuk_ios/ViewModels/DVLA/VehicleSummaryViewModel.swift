import Foundation
import GovKit

struct VehicleSummaryViewModel: Identifiable {
    let id: Int
    let registrationNumber: String
    let vehicleMake: String
    let vehicleModel: String
    let taxStatusViewModel: ValidityStatusViewModel
    let motStatusViewModel: ValidityStatusViewModel
    let detailAction: () -> Void
    let regNumberAccessibilityLabelPrefix = String(
        localized: .DVLA.registrationNumberAccessibilityLabelPrefix
    )
    private let openURLAction: (URL) -> Void
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
}

extension VehicleSummaryViewModel {
    init(
        vehicle: CustomerSummary.Vehicle,
        statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter(),
        specFormatter: VehicleSpecFormatter = VehicleSpecFormatter(),
        detailAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void,
        configService: AppConfigServiceInterface,
        analyticsService: AnalyticsServiceInterface
    ) {
        self.id = vehicle.vehicleId
        self.registrationNumber = vehicle.registrationNumber
        self.vehicleMake = vehicle.make
        self.vehicleModel = specFormatter.formatModel(from: vehicle.model)

        self.taxStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("taxStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.taxedUntil),
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
        )
        self.motStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("motStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.motExpiryDate),
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
        )
        self.detailAction = detailAction
        self.openURLAction = openURLAction
        self.configService = configService
        self.analyticsService = analyticsService
    }
}

extension VehicleSummaryViewModel {
    var menuItems: [MenuItemViewModel] {
        [
            .init(
                title: String(localized: .DVLA.vehicleMenuSornRulesTitle),
                accessibilityLabel: nil,
                openURLAction: { text in openSornRulesURL(text) }
            ),
            .init(
                title: String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
                accessibilityLabel: String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
                openURLAction: { text in openSoldVehicleURL(text) }
            ),
            .init(
                title: String(localized: .DVLA.vehicleMenuMakeSornTitle),
                accessibilityLabel: String(localized: .DVLA.vehicleMenuMakeSornTitle),
                openURLAction: { text in openMakeSornURL(text) }
            ),
            .init(
                title: String(localized: .DVLA.vehicleMenuGetLogbookTitle),
                accessibilityLabel: nil,
                openURLAction: { text in openGetLogbookURL(text) }
            ),
            .init(
                title: String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
                accessibilityLabel: nil,
                openURLAction: { text in openChangeLogbookAddressURL(text) }
            ),
            .init(
                title: String(localized: .DVLA.vehicleMenuCancelTaxTitle),
                accessibilityLabel: String(localized: .DVLA.vehicleMenuCancelTaxTitle),
                openURLAction: { text in openCancelTaxURL(text) }
            )
        ]
    }

    private func openSornRulesURL(_ text: String) {
        let url = configService.dvlaUrls?.sornRules ??
        Constants.API.defaultDvlaSornRulesUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openSoldVehicleURL(_ text: String) {
        let url = configService.dvlaUrls?.soldVehicle ??
        Constants.API.defaultDvlaSoldVehicleUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openMakeSornURL(_ text: String) {
        let url = configService.dvlaUrls?.makeSorn ??
        Constants.API.defaultDvlaMakeSornUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openGetLogbookURL(_ text: String) {
        let url = configService.dvlaUrls?.getLogbook ??
        Constants.API.defaultDvlaGetLogbookUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openChangeLogbookAddressURL(_ text: String) {
        let url = configService.dvlaUrls?.changeLogbookAddress ??
        Constants.API.defaultDvlaChangeLogbookAddressUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openCancelTaxURL(_ text: String) {
        let url = configService.dvlaUrls?.cancelTax ??
        Constants.API.defaultDvlaCancelTaxUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openMenuURLAction(url: URL, text: String) {
        openURLAction(url)
        trackUrlOpenEvent(url: url, text: text)
    }

    private func trackUrlOpenEvent(url: URL, text: String) {
        let event = AppEvent.navigation(
            text: text,
            type: "VehicleMenuLink",
            external: true,
            additionalParams: [
                "url": url.absoluteString
            ]
        )
        analyticsService.track(event: event)
    }
}
