import Foundation

@testable import govuk_ios

extension CustomerVehicleDetails {
    static var arrange: CustomerVehicleDetails {
        arrange()
    }

    static func arrange(
        customerVehicleDetails: CustomerVehicleDetails.Vehicle = .arrange
    ) -> CustomerVehicleDetails {
        .init(
            customerVehicleDetails: customerVehicleDetails
        )
    }
}

extension CustomerVehicleDetails.Vehicle {
    static var arrange: CustomerVehicleDetails.Vehicle {
        arrange()
    }

    static func arrange(
        vehicleId: Int = 1,
        registrationNumber: String = "AB71 CDE",
        make: String = "MITSUBISHI",
        model: String? = "MIRAGE",
        taxStatus: TaxStatus? = .taxed,
        taxedUntil: Date? = nil,
        dateOfLiability: Date? = nil,
        motStatus: String = "Not valid",
        motExpiryDate: Date? = nil,
        dateOfFirstRegistration: Date = .arrange("12/03/2021"),
        colour: String = "YELLOW",
        secondaryColour: String? = nil,
        fuelType: FuelType = .petrol,
        exhaustEmissionsCo2: Int? = 500,
        engineCapacity: Int? = 1995,
        sornStart: Date? = nil,
        currentLicencePaymentMethod: String? = nil,
        dateOfManufacture: Date? = nil,
        keeperTitle: String? = "MRS",
        keeperFirstNames: String? = "JANE",
        keeperLastName: String? = "BLOGGS",
        keeperFullAddress: String? = "75 ST JOHN'S STREET\nGATESHEAD\nNE8 2ED"
    ) -> CustomerVehicleDetails.Vehicle {
        .init(
            vehicleId: vehicleId,
            registrationNumber: registrationNumber,
            make: make,
            model: model,
            motStatus: motStatus,
            dateOfFirstRegistration: dateOfFirstRegistration,
            fuelType: fuelType,
            colour: colour,
            taxStatus: taxStatus,
            dateOfLiability: dateOfLiability,
            sornStart: sornStart,
            taxedUntil: taxedUntil,
            currentLicencePaymentMethod: currentLicencePaymentMethod,
            motExpiryDate: motExpiryDate,
            dateOfManufacture: dateOfManufacture,
            secondaryColour: secondaryColour,
            keeperTitle: keeperTitle,
            keeperFirstNames: keeperFirstNames,
            keeperLastName: keeperLastName,
            keeperFullAddress: keeperFullAddress,
            engineCapacity: engineCapacity,
            exhaustEmissionsCo2: exhaustEmissionsCo2

        )
    }
}
