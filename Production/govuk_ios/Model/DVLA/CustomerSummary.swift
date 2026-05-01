import Foundation

struct CustomerSummary: Codable {
    let customerResponse: CustomerResponse
    let linkingId: String?

    let vehicles: [Vehicle]
    enum CodingKeys: String, CodingKey {
        case customerResponse = "customerResponse"
        case vehicles = "vehicleResponse"
        case linkingId = "linkingId"
    }
}

struct CustomerResponse: Codable {
    let customer: Customer
}

struct Vehicle: Codable {
    let vehicleId: Int
    let registrationNumber: String
    let make: String
    let model: String?
    let taxStatus: String
    let motStatus: String
}

struct Customer: Codable {
    let customerType: String
    let individualDetails: IndividualDetails
}

struct IndividualDetails: Codable {
    let firstNames: String
    let lastName: String
}
