import Foundation

struct VehicleSummaryViewModel: Identifiable {
    let id: Int
    let registrationNumber: String
    let registrationNumberAccessibilityLabel: String
    let vehicleMake: String
    let vehicleModel: String
    let taxStatusViewModel: ValidityStatusViewModel
    let motStatusViewModel: ValidityStatusViewModel

    init(
        vehicle: CustomerSummary.Vehicle,
        statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter()
    ) {
        self.id = vehicle.vehicleId
        self.registrationNumber = vehicle.registrationNumber
        self.vehicleMake = vehicle.make
        self.vehicleModel = vehicle.model ?? String.dvla.localized("unknown")

        self.taxStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("taxStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.taxedUntil)
        )
        self.motStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("motStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.motExpiryDate)
        )

        let format = String.dvla.localized("registrationNumberAccessibilityLabel")
        self.registrationNumberAccessibilityLabel = .localizedStringWithFormat(
            format,
            vehicle.registrationNumber
        )
    }
}
