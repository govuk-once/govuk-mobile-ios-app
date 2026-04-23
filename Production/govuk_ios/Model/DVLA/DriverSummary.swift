import Foundation

struct DriverSummary: Codable {
    let response: DriverViewResponse
    enum CodingKeys: String, CodingKey {
        case response = "driverViewResponse"
    }
}

struct DriverViewResponse: Codable {
    struct Driver: Codable {
        let licenceNo: String
        let firstNames: String
        let lastName: String
        let penaltyPoints: Int
        enum CodingKeys: String, CodingKey {
            case licenceNo = "drivingLicenceNumber"
            case firstNames = "firstNames"
            case lastName = "lastName"
            case penaltyPoints = "penaltyPoints"
        }
    }
    let driver: Driver
    let licence: Licence
    let token: DrivingLicenceToken
}
