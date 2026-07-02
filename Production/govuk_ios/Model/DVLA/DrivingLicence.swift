import Foundation

struct DrivingLicence: Codable {
    struct Driver: Codable {
        let licenceNo: String
        enum CodingKeys: String, CodingKey {
            case licenceNo = "drivingLicenceNumber"
        }
    }
    let driver: Driver
    let licence: Licence
    let token: DrivingLicenceToken
}
