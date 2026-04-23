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
        vehicleResponse: [VehicleResponse] = []
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
            vehicleResponse: vehicleResponse
        )
    }
}

extension VehicleResponse {
    static var arrange: VehicleResponse {
        arrange()
    }

    static func arrange(
        vehicleId: Int = 1,
        registrationNumber: String = "AB71 CDE",
        make: String = "MITSUBISHI",
        model: String = "MIRAGE",
        taxStatus: String = "Taxed",
        motStatus: String = "Not valid"
    ) -> VehicleResponse {
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


