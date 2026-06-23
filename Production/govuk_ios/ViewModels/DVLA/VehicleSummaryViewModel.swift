import Foundation
import GovKitUI

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
}

extension VehicleSummaryViewModel {
    init(
        vehicle: CustomerSummary.Vehicle,
        statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter(),
        specFormatter: VehicleSpecFormatter = VehicleSpecFormatter(),
        detailAction: @escaping () -> Void
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
    }
}
