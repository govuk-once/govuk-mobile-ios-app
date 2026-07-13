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
    private let sornStart: Date?
    private let taxStatus: TaxStatus?
    private let openURLAction: (URL) -> Void
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
}

extension VehicleSummaryViewModel {
    @MainActor
    init(
        vehicle: CustomerSummary.Vehicle,
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
        self.sornStart = vehicle.sornStart
        self.taxStatus = vehicle.taxStatus

        let builder = TaxStatusViewModelBuilder(
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        self.taxStatusViewModel = builder.makeViewModel(
            vehicle: vehicle
        )
        let motBuilder = MotStatusViewModelBuilder(
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        self.motStatusViewModel = motBuilder.makeViewModel(
            vehicle: vehicle
        )

        self.detailAction = detailAction
        self.openURLAction = openURLAction
        self.configService = configService
        self.analyticsService = analyticsService
    }
}

extension VehicleSummaryViewModel {
    var menuItems: [DvlaMenuItemViewModel] {
        var items: [DvlaMenuItemViewModel] = []
        if sornStart != nil {
            items.append(
                DvlaMenuItemViewModel(
                    title: String(localized: .DVLA.vehicleMenuSornRulesTitle),
                    accessibilityLabel: nil,
                    openURLAction: { text in openSornRulesURL(text) }
                )
            )
        }
        items.append(
            DvlaMenuItemViewModel(
                title: String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
                accessibilityLabel: String(
                    localized: .DVLA.vehicleMenuSoldVehicleAccessibilityLabelTitle
                ),
                openURLAction: { text in openSoldVehicleURL(text) }
            )
        )
        if sornStart == nil {
            items.append(
                DvlaMenuItemViewModel(
                    title: String(localized: .DVLA.vehicleMenuMakeSornTitle),
                    accessibilityLabel: String(
                        localized: .DVLA.vehicleMenuMakeSornAccessibilityLabelTitle
                    ),
                    openURLAction: { text in openMakeSornURL(text) }
                )
            )
        }
        items.append(
            DvlaMenuItemViewModel(
                title: String(localized: .DVLA.vehicleMenuGetLogbookTitle),
                accessibilityLabel: nil,
                openURLAction: { text in openGetLogbookURL(text) }
            )
        )
        items.append(
            DvlaMenuItemViewModel(
                title: String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
                accessibilityLabel: nil,
                openURLAction: { text in openChangeLogbookAddressURL(text) }
            )
        )
        if taxStatus == .taxed {
            items.append(
                DvlaMenuItemViewModel(
                    title: String(localized: .DVLA.vehicleMenuCancelTaxTitle),
                    accessibilityLabel: String(
                        localized: .DVLA.vehicleMenuCancelTaxAccessibilityLabelTitle
                    ),
                    openURLAction: { text in openCancelTaxURL(text) }
                )
            )
        }
        return items
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
        let event = AppEvent.buttonNavigation(
            text: text,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }
}
