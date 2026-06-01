import Foundation

struct VehicleSummaryViewModel: Identifiable {
    private let vehicle: CustomerSummary.Vehicle
    private let dateFormatter = DateFormatter.dvlaAccount

    var id: String {
        vehicle.registrationNumber
    }

    var registrationNumber: String {
        vehicle.registrationNumber
    }

    var registrationNumberAccessibilityLabel: String {
        let format = String.dvla.localized("registrationNumberAccessibilityLabel")
        return String.localizedStringWithFormat(format, registrationNumber)
    }

    var vehicleMake: String {
        vehicle.make
    }

    var vehicleModel: String {
        vehicle.model ?? String.dvla.localized("unknown")
    }

    var taxStatusViewModel: ValidityStatusViewModel {
        .init(
            title: String.dvla.localized("taxStatusTitle"),
            status: formatValidityStatus(from: vehicle.taxedUntil)
        )
    }

    var motStatusViewModel: ValidityStatusViewModel {
        .init(
            title: String.dvla.localized("motStatusTitle"),
            status: formatValidityStatus(from: vehicle.motExpiryDate)
        )
    }

    init(vehicle: CustomerSummary.Vehicle) {
        self.vehicle = vehicle
    }

    private func formatValidityStatus(from expiryDate: Date?) -> String {
        if let expiryDate = expiryDate {
            let expiryDateString = dateFormatter.string(from: expiryDate)
            let format = String.dvla.localized("vehicleSummaryValidUntil")
            return String.localizedStringWithFormat(format, expiryDateString)
        } else {
            return String.dvla.localized("unknown")
        }
    }
}
