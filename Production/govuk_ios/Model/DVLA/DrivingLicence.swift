import Foundation

struct DrivingLicenceResponse: Codable {
    let customerDrivingLicence: DrivingLicence
}

struct DrivingLicence: Codable {
    let licenceType: String
    let licenceNumber: String
    let driverTitle: String?
    let driverFirstNames: String?
    let driverLastName: String?
    let driverFullAddress: String?
    let tokenValidToDate: Date?
    let licenceStatus: DrivingLicenceStatus

    enum CodingKeys: String, CodingKey {
        case licenceType = "licenceType"
        case licenceNumber = "drivingLicenceNumber"
        case driverTitle = "driverTitle"
        case driverFirstNames = "driverFirstNames"
        case driverLastName = "driverLastName"
        case driverFullAddress = "driverFullAddress"
        case tokenValidToDate = "tokenValidToDate"
        case licenceStatus = "licenceStatus"
    }
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
