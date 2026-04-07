import Foundation

struct DrivingLicence: Codable {
    let driver: Driver
    let licence: Licence
    let token: DrivingLicenceToken
}

struct Driver: Codable {
    let drivingLicenceNumber: String
}

struct Licence: Codable {
    let type: String
    let status: String
}

struct DrivingLicenceToken: Codable {
    let validFromDate: Date
    let validToDate: Date
}
