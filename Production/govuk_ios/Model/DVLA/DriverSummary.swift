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
    let token: DrivingLicenceToken?
}

struct Licence: Codable {
    let type: String
    let status: DrivingLicenceStatus
}

enum DrivingLicenceStatus: String, Codable {
    case valid = "Valid"
    case disqualified = "Disqualified"
    case revoked = "Revoked"
    case revokedForMedicalReasons = "Revoked for medical reasons"
    case surrendered = "Surrendered"
    case surrenderedVoluntarily = "Surrendered voluntarily"
    case surrenderedForMedicalReasons = "Surrendered for medical reasons"
    case expired = "Expired"
    case exchanged = "Exchanged"
    case refused = "Refused"
    case refusedForMedicalReasons = "Refused for medical reasons"
}

struct DrivingLicenceToken: Codable {
    let validFromDate: Date
    let validToDate: Date?
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
