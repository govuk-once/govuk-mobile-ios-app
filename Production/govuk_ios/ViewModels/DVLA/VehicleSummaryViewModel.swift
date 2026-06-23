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

    func openSoldVehicleURL() {
        let url = configService.dvlaUrls?.soldVehicle ??
        Constants.API.defaultDvlaSoldVehicleUrl
        openURLAction(url)
    }

    func openSornRulesURL() {
        let url = configService.dvlaUrls?.sornRules ??
        Constants.API.defaultDvlaSornRulesUrl
        openURLAction(url)
    }

    func openMakeSornURL() {
        let url = configService.dvlaUrls?.makeSorn ??
        Constants.API.defaultDvlaMakeSornUrl
        openURLAction(url)
    }

    func openGetLogbookURL() {
        let url = configService.dvlaUrls?.getLogbook ??
        Constants.API.defaultDvlaGetLogbookUrl
        openURLAction(url)
    }

    func openChangeLogbookAddressURL() {
        let url = configService.dvlaUrls?.changeLogbookAddress ??
        Constants.API.defaultDvlaChangeLogbookAddressUrl
        openURLAction(url)
    }

    func openCancelTaxURL() {
        let url = configService.dvlaUrls?.cancelTax ??
        Constants.API.defaultDvlaCancelTaxUrl
        openURLAction(url)
    }
}

extension VehicleSummaryViewModel {
    init(
        vehicle: CustomerSummary.Vehicle,
        statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter(),
        specFormatter: VehicleSpecFormatter = VehicleSpecFormatter(),
        detailAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void,
        configService: AppConfigServiceInterface
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
    }
}
