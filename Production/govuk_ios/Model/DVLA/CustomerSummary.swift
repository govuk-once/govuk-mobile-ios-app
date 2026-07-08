import Foundation

struct CustomerSummary: Codable {
    struct Vehicle: Codable {
        let vehicleId: Int
        let registrationNumber: String
        let make: String
        let model: String?
        let taxStatus: TaxStatus
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
        let sornStart: Date?
    }

    let vehicles: [Vehicle]

    enum CodingKeys: String, CodingKey {
        case vehicles = "vehicleResponse"
    }
}

enum TaxStatus: String, Codable {
    case notTaxedForOnRoadUse = "Not Taxed for on Road Use"
    case sorn = "SORN"
    case untaxed = "Untaxed"
    case taxed = "Taxed"
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

struct UnstructuredAddress: Codable {
    let line1: String?
    let line2: String?
    let line3: String?
    let line4: String?
    let line5: String?
    let postcode: String?
}
