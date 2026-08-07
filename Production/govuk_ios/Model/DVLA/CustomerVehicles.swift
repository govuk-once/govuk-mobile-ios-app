import Foundation

struct CustomerVehicles: Codable {
    struct Vehicle: Codable {
        let vehicleId: Int
        let registrationNumber: String
        let make: String
        let model: String?
        let motStatus: String
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
}
