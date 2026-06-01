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
    }

    let customerResponse: CustomerResponse
    let vehicles: [Vehicle]

    enum CodingKeys: String, CodingKey {
        case customerResponse = "customerResponse"
        case vehicles = "vehicleResponse"
    }
}

struct CustomerResponse: Codable {
    let customer: Customer
}

struct Customer: Codable {
    let customerType: String
    let individualDetails: IndividualDetails
}

struct IndividualDetails: Codable {
    let firstNames: String
    let lastName: String
}
