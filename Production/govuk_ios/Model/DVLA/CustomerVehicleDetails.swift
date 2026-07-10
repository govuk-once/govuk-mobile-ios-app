import Foundation

struct CustomerVehicleDetails: Codable {
    struct Vehicle: Codable {
        let vehicleId: Int
        let registrationNumber: String
        let make: String
        let model: String?
        let motStatus: String
        let dateOfFirstRegistration: Date
        let fuelType: FuelType
        let colour: String
        let taxStatus: TaxStatus?
        let dateOfLiability: Date?
        let sornStart: Date?
        let taxedUntil: Date?
        let currentLicencePaymentMethod: String?
        let motExpiryDate: Date?
        let dateOfManufacture: Date?
        let secondaryColour: String?
        let keeperTitle: String?
        let keeperFirstNames: String?
        let keeperLastName: String?
        let keeperFullAddress: String?
        let engineCapacity: Int?
        let exhaustEmissionsCo2: Int?
    }

    let customerVehicleDetails: Vehicle
}

enum FuelType: String, Codable {
    case petrol = "PETROL"
    case diesel = "DIESEL"
    case electricity = "ELECTRICITY"
    case steam = "STEAM"
    case gas = "GAS"
    case petrolGas = "PETROL/GAS"
    case gasBiFuel = "GAS BI-FUEL"
    case hybridElectric = "HYBRID ELECTRIC"
    case gasDiesel = "GAS DIESEL"
    case fuelCells = "FUEL CELLS"
    case electricDiesel = "ELECTRIC DIESEL"
    case other = "OTHER"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = FuelType(rawValue: rawValue) ?? .unknown
    }
}
