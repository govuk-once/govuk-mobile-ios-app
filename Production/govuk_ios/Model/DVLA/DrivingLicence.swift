import Foundation

struct DrivingLicence: Codable {
    struct Driver: Codable {
        let drivingLicenceNumber: String
    }

    let driver: Driver
    let licence: Licence
    let token: DrivingLicenceToken
}

struct Licence: Codable {
    let type: String
    let status: String
}

struct DrivingLicenceToken: Codable {
    let validFromDate: Date
    let validToDate: Date
}
