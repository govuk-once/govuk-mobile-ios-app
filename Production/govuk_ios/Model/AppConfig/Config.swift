import Foundation

struct Config: Decodable {
    enum CodingKeys: String, CodingKey {
        case available
        case minimumVersion
        case recommendedVersion
        case releaseFlags
        case lastUpdated
        case searchApiUrl
        case authenticationIssuerBaseUrl
        case chatPollIntervalSeconds
        case refreshTokenExpirySeconds
        case alertBanner
        case chatBanner = "chatBanner_v2"
        case userFeedbackBanner
        case emergencyBanners
        case chatUrls
        case termsAndConditions
        case dvlaUrls
    }

    let available: Bool
    let minimumVersion: String
    let recommendedVersion: String
    let releaseFlags: [String: Bool]
    let lastUpdated: String
    let searchApiUrl: String?
    var authenticationIssuerBaseUrl: String?
    let chatPollIntervalSeconds: TimeInterval?
    let refreshTokenExpirySeconds: Int?
    let alertBanner: AlertBanner?
    let chatBanner: ChatBanner?
    let userFeedbackBanner: UserFeedbackBanner?
    let emergencyBanners: [EmergencyBanner]?
    let chatUrls: ChatURLs?
    let termsAndConditions: TermsAndConditions
    let dvlaUrls: DvlaURLs?
}

struct ChatURLs: Decodable {
    let termsAndConditions: URL?
    let privacyNotice: URL?
    let about: URL?
    let feedback: URL?
}

struct DvlaURLs: Decodable {
    let addVehicle: URL?
    let renewLicence: URL?
    let soldVehicle: URL?
    let sornRules: URL?
    let makeSorn: URL?
    let getLogbook: URL?
    let changeLogbookAddress: URL?
    let cancelTax: URL?
    let taxVehicle: URL?
    let manageTaxPayment: URL?
    let driverDetails: URL?
    let account: URL?
    let drivingRecord: URL?
}

struct TermsAndConditions: Decodable {
    let url: URL
    let contentItemApiPath: String
    var lastUpdated: Date?
}
