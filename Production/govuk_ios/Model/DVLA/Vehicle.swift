import Foundation

struct Vehicle: Codable {
    let registrationNumber: String
    let fuelType: String
    let motStatus: String
    let colour: String
    let make: String
    let model: String?
    let taxStatus: String
    let taxDueDate: Date
}
