import Foundation

struct VehicleSummaryViewModel: Identifiable {
    let id: Int
    let registrationNumber: String
    let vehicleMake: String
    let vehicleModel: String
    let taxStatusViewModel: ValidityStatusViewModel
    let motStatusViewModel: ValidityStatusViewModel
    let detailTappedAction: () -> Void
    let regNumberAccessibilityLabelPrefix = String(
        localized: .DVLA.registrationNumberAccessibilityLabelPrefix
    )
}

extension VehicleSummaryViewModel {
    init(
        vehicle: CustomerSummary.Vehicle,
        statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter(),
        specFormatter: VehicleSpecFormatter = VehicleSpecFormatter(),
        detailTappedAction: @escaping () -> Void
    ) {
        self.id = vehicle.vehicleId
        self.registrationNumber = vehicle.registrationNumber
        self.vehicleMake = vehicle.make
        self.vehicleModel = specFormatter.formatModel(from: vehicle.model)

        self.taxStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("taxStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.taxedUntil)
        )
        self.motStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("motStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.motExpiryDate)
        )
        self.detailTappedAction = detailTappedAction
    }
}
