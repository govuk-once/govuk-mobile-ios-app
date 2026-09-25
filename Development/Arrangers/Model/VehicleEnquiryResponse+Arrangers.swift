#if DEBUG
import Foundation

extension VehicleEnquiryResponse {
    static var arrange: VehicleEnquiryResponse {
        arrange()
    }
    
    static func arrange(
        vehicle: Vehicle = .arrange
    ) -> VehicleEnquiryResponse {
        .init(vehicle: vehicle)
    }
}

extension VehicleEnquiryResponse.Vehicle {
    static var arrange: VehicleEnquiryResponse.Vehicle {
        arrange()
    }
    
    static func arrange(
        vehicleId: Int = 1,
        registrationNumber: String = "AA19AMP",
        taxStatus: TaxStatus? = .taxed,
        taxedUntil: Date? = .arrange("15/09/2026"),
        motStatus: String? = "Valid",
        motExpiryDate: Date? = .arrange("15/09/2026"),
        make: String? = "FORD",
        dateOfFirstRegistration: Date? = .arrange("01/05/2000"),
        engineCapacity: Int? = 2000,
        exhaustEmissionsCo2: Int? = 350,
        fuelType: FuelType? = .diesel,
        colour: String? = "BLACK",
        secondaryColour: String? = nil
    ) -> VehicleEnquiryResponse.Vehicle {
        .init(
            vehicleId: vehicleId,
            registrationNumber: registrationNumber,
            taxStatus: taxStatus,
            taxedUntil: taxedUntil,
            motStatus: motStatus,
            motExpiryDate: motExpiryDate,
            make: make,
            dateOfFirstRegistration: dateOfFirstRegistration,
            engineCapacity: engineCapacity,
            exhaustEmissionsCo2: exhaustEmissionsCo2,
            fuelType: fuelType,
            colour: colour,
            secondaryColour: secondaryColour
        )
    }
}
#endif // DEBUG
