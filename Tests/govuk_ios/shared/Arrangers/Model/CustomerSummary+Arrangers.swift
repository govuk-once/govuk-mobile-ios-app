import Foundation

@testable import govuk_ios

extension CustomerSummary {
    static var arrange: CustomerSummary {
        arrange()
    }

    static func arrange(
        firstNames: String = "KENNETH",
        lastName: String = "DECERQUEIRA",
        customerType: String = "Individual",
        vehicles: [CustomerSummary.Vehicle] = [.arrange]
    ) -> CustomerSummary {
        .init(
            vehicles: vehicles
        )
    }
}

extension CustomerSummary.Vehicle {
    static var arrange: CustomerSummary.Vehicle {
        arrange()
    }

    static func arrange(
        vehicleId: Int = 1,
        registrationNumber: String = "AB71 CDE",
        make: String = "MITSUBISHI",
        model: String? = "MIRAGE",
        taxStatus: TaxStatus = .taxed,
        taxedUntil: Date? = nil,
        motStatus: String = "Not valid",
        motExpiryDate: Date? = nil,
        dateOfFirstRegistration: Date = .arrange("12/03/2021"),
        colour: String = "YELLOW",
        secondaryColour: String? = nil,
        fuelType: FuelType = .petrol,
        exhaustEmissions: ExhaustEmissions? = .arrange,
        engineCapacity: Int? = 1995,
        keeper: VehicleKeeper? = .arrange,
        sornStart: Date? = nil,
        currentLicence: CurrentLicence? = nil
    ) -> CustomerSummary.Vehicle {
        .init(
            vehicleId: vehicleId,
            registrationNumber: registrationNumber,
            make: make,
            model: model,
            taxStatus: taxStatus,
            taxedUntil: taxedUntil,
            motStatus: motStatus,
            motExpiryDate: motExpiryDate,
            dateOfFirstRegistration: dateOfFirstRegistration,
            colour: colour,
            secondaryColour: secondaryColour,
            fuelType: fuelType,
            exhaustEmissions: exhaustEmissions,
            engineCapacity: engineCapacity,
            keeper: keeper,
            sornStart: sornStart,
            currentLicence: currentLicence
        )
    }
}

extension VehicleKeeper {
    static var arrange: VehicleKeeper {
        arrange()
    }
    static func arrange(
        title: String? = "MRS",
        firstNames: String? = "JANE",
        lastName: String? = "BLOGGS",
        address: VehicleKeeperAddress? = .arrange
    ) -> VehicleKeeper {
        .init(
            title: title,
            firstNames: firstNames,
            lastName: lastName,
            address: address
        )
    }
}

extension VehicleKeeperAddress {
    static var arrange: VehicleKeeperAddress {
        arrange()
    }
    static func arrange(
        line1: String? = "75 ST JOHN'S STREET",
        line2: String? = "GATESHEAD",
        line3: String? = nil,
        line4: String? = nil,
        line5: String? = nil,
        postcode: String? = "NE8 2ED"
    ) -> VehicleKeeperAddress {
        .init(
            unstructuredAddress: .init(
                line1: line1,
                line2: line2,
                line3: line3,
                line4: line4,
                line5: line5,
                postcode: postcode
            )
        )
    }
}

extension ExhaustEmissions {
    static var arrange: ExhaustEmissions {
        arrange()
    }
    static func arrange(
        co2: Int? = 500
    ) -> ExhaustEmissions {
        .init(
            co2: co2
        )
    }
}


