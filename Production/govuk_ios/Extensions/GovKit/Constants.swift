import GovKit
import Foundation

extension Constants.API {
    public static let defaultChatPrivacyPolicyUrl: URL = {
        var components = govukBaseComponents
        components.path = """
            /government/publications/govuk-chat-privacy-notice
            """
        return components.url!
    }()

    public static let defaultChatTermsUrl: URL = {
        var components = govukBaseComponents
        components.path = """
            /guidance/govuk-chat-terms-and-conditions
            """
        return components.url!
    }()

    public static let defaultChatAboutUrl: URL = {
        var components = govukBaseComponents
        components.path = """
            /guidance/about-govuk-chat
            """
        return components.url!
    }()

    public static let defaultChatFeedbackUrl: URL =
    URL(string: "https://surveys.publishing.service.gov.uk/s/SUIEH2/")!
}

extension Constants {
    public struct Timers {
        public struct Thresholds {
            public static let inactivityTimeout: TimeInterval = 15 * 60
            public static let inactivityWarning: TimeInterval = 13 * 60
        }
    }
}
