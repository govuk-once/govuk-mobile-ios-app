import Foundation

struct DriverSummary: Codable {
    let driverViewResponse: DriverViewResponse
}

struct DriverViewResponse: Codable {
    struct Driver: Codable {
        let drivingLicenceNumber: String
        let firstNames: String
        let lastName: String
        let penaltyPoints: Int
    }
    let driver: Driver
    let licence: Licence
    let token: DrivingLicenceToken
}
