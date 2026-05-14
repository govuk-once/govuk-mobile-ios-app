import Foundation

struct ShareCodeListResponse: Codable {
    let shareCodes: [ShareCode]
}

struct ShareCodeResponse: Codable {
    let shareCode: ShareCode
}

struct ShareCode: Codable {
    let state: String
    let tokenId: String
    let token: String
    let drivingLicenceNumber: String
    let driverId: String
    let documentReference: String
    let created: Date
    let expiry: Date
    let status: String?
    let redeemed: Date?
    let cancelled: Date?
}
