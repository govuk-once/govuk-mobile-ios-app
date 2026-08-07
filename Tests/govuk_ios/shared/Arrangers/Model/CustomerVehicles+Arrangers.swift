import Foundation

@testable import govuk_ios

extension CustomerVehicles {
    static var arrange: CustomerVehicles {
        arrange()
    }

    static func arrange(
        customerVehicles: [CustomerVehicles.Vehicle] = [.arrange]
    ) -> CustomerVehicles {
        .init(
            customerVehicles: customerVehicles
        )
    }
}

extension CustomerVehicles.Vehicle {
    static var arrange: CustomerVehicles.Vehicle {
        arrange()
    }

    static func arrange(
        vehicleId: Int = 1,
        registrationNumber: String = "AB71 CDE",
        make: String = "MITSUBISHI",
        model: String? = "MIRAGE",
        taxStatus: TaxStatus? = .taxed,
        taxedUntil: Date? = nil,
        motStatus: String = "Not valid",
        motExpiryDate: Date? = nil,
        dateOfLiability: Date? = nil,
        sornStart: Date? = nil,
        currentLicencePaymentMethod: String? = nil
    ) -> CustomerVehicles.Vehicle {
        .init(
            vehicleId: vehicleId,
            registrationNumber: registrationNumber,
            make: make,
            model: model,
            motStatus: motStatus,
            taxStatus: taxStatus,
            dateOfLiability: dateOfLiability,
            sornStart: sornStart,
            taxedUntil: taxedUntil,
            motExpiryDate: motExpiryDate,
            currentLicencePaymentMethod: currentLicencePaymentMethod
        )
    }
}
