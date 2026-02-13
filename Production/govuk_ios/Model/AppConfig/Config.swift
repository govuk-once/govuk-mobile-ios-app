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
}

struct ChatURLs: Decodable {
    let termsAndConditions: URL?
    let privacyNotice: URL?
    let about: URL?
    let feedback: URL?
}

struct TermsAndConditions: Decodable {
    let url: URL
    let lastUpdated: String
}
