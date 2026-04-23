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
        vehicles: [Vehicle] = []
    ) -> CustomerSummary {
        .init(
            customerResponse: .init(
                customer: .init(
                    customerType: customerType,
                    individualDetails: .init(
                        firstNames: firstNames,
                        lastName: lastName
                    )
                )
            ),
            vehicles: vehicles
        )
    }
}

extension Vehicle {
    static var arrange: Vehicle {
        arrange()
    }

    static func arrange(
        vehicleId: Int = 1,
        registrationNumber: String = "AB71 CDE",
        make: String = "MITSUBISHI",
        model: String = "MIRAGE",
        taxStatus: String = "Taxed",
        motStatus: String = "Not valid"
    ) -> Vehicle {
        .init(
            vehicleId: vehicleId,
            registrationNumber: registrationNumber,
            make: make,
            model: model,
            taxStatus: taxStatus,
            motStatus: motStatus
        )
    }
}


