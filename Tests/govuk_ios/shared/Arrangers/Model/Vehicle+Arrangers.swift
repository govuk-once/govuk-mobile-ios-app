import Foundation

@testable import govuk_ios

extension Vehicle {
    static var arrange: Vehicle {
        arrange()
    }

    static func arrange(
        registrationNumber: String = "AA19AMP",
        fuelType: String = "DIESEL",
        motStatus: String = "Valid",
        colour: String = "BLACK",
        make: String = "FORD",
        model: String? = nil,
        taxStatus: String = "Taxed",
        taxDueDate: Date = .init(timeIntervalSince1970: 0),
    ) -> Vehicle {
        .init(
            registrationNumber: registrationNumber,
            fuelType: fuelType,
            motStatus: motStatus,
            colour: colour,
            make: make,
            model: model,
            taxStatus: taxStatus,
            taxDueDate: taxDueDate
        )
    }
}
