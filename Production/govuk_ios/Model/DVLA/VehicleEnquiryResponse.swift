import Foundation

struct VehicleEnquiryResponse: Codable {
    struct Vehicle: Codable {
        let vehicleId: Int
        let registrationNumber: String
        let taxStatus: TaxStatus?
        let taxedUntil: Date?
        let motStatus: String?
        let motExpiryDate: Date?
        let make: String?
        let dateOfFirstRegistration: Date?
        let engineCapacity: Int?
        let exhaustEmissionsCo2: Int?
        let fuelType: FuelType?
        let colour: String?
        let secondaryColour: String?
    }
    let vehicle: Vehicle
}
