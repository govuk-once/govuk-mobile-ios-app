import Foundation

struct CustomerVehicles: Codable {
    struct Vehicle: Codable {
        let vehicleId: Int
        let registrationNumber: String
        let make: String
        let model: String?
        let motStatus: MotStatus
        let taxStatus: TaxStatus?
        let dateOfLiability: Date?
        let sornStart: Date?
        let taxedUntil: Date?
        let motExpiryDate: Date?
        let currentLicencePaymentMethod: String?
    }

    let customerVehicles: [Vehicle]
}

enum TaxStatus: String, Codable {
    case notTaxedForOnRoadUse = "Not Taxed for on Road Use"
    case sorn = "SORN"
    case untaxed = "Untaxed"
    case taxed = "Taxed"

    var isNotTaxed: Bool {
        [.untaxed, .sorn, .notTaxedForOnRoadUse].contains(self)
    }
}

enum MotStatus: String, Codable {
    case valid = "Valid"
    case notValid = "Not valid"
    case noResultsReturned = "No results returned"
    case noDetailsHeldByDVLA = "No details held by DVLA"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = MotStatus(rawValue: rawValue) ?? .unknown
    }
}
