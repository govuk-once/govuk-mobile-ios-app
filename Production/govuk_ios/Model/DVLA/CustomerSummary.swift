import Foundation

struct CustomerSummary: Codable {
    struct Vehicle: Codable {
        let vehicleId: Int
        let registrationNumber: String
        let make: String
        let model: String?
        let taxStatus: String
        let taxedUntil: Date?
        let motStatus: String
        let motExpiryDate: Date?
        let dateOfFirstRegistration: Date
        let colour: String
        let secondaryColour: String?
        let fuelType: FuelType
        let exhaustEmissions: ExhaustEmissions?
        let engineCapacity: Int?
        let keeper: VehicleKeeper?
    }

    let vehicles: [Vehicle]

    enum CodingKeys: String, CodingKey {
        case vehicles = "vehicleResponse"
    }
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
}

struct ExhaustEmissions: Codable {
    let co2: Int?
}

struct VehicleKeeper: Codable {
    let title: String?
    let firstNames: String?
    let lastName: String?
    let address: VehicleKeeperAddress?
}

struct VehicleKeeperAddress: Codable {
    let unstructuredAddress: UnstructuredAddress?
}
