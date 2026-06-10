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
        let title: String?
        let firstNames: String?
        let lastName: String?
        let penaltyPoints: Int
        let address: DriverAddress
        enum CodingKeys: String, CodingKey {
            case licenceNo = "drivingLicenceNumber"
            case firstNames = "firstNames"
            case lastName = "lastName"
            case title = "title"
            case penaltyPoints = "penaltyPoints"
            case address = "address"
        }
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

struct DriverAddress: Codable {
    let unstructuredAddress: UnstructuredAddress
}

struct UnstructuredAddress: Codable {
    let line1: String?
    let line2: String?
    let line3: String?
    let line4: String?
    let line5: String?
    let postcode: String?
}
