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

    public static let defaultDvlaNoResultsUrl: URL = {
        var components = govukBaseComponents
        components.path = "/historic-vehicles"
        return components.url!
    }()


    public static let defaultDvlaNoDetailsBaseUrlString = "https://www.check-mot.service.gov.uk/results"

    public static let defaultChatFeedbackUrl: URL = URL(
        string: "https://surveys.publishing.service.gov.uk/s/SUIEH2/"
    )!

    public static let defaultDvlaAddVehicleUrl: URL = URL(
        string: "https://driver-and-vehicles-account.service.gov.uk/add_vehicle"
    )!

    public static let defaultDvlaSoldVehicleUrl: URL = URL(
        string: "https://www.gov.uk/sold-bought-vehicle"
    )!

    public static let defaultDvlaSornRulesUrl: URL = URL(
        string: "https://www.gov.uk/sorn-statutory-off-road-notification"
    )!

    public static let defaultDvlaMakeSornUrl: URL = URL(
        string: "https://www.gov.uk/make-a-sorn"
    )!

    public static let defaultDvlaGetLogbookUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-log-book"
    )!

    public static let defaultDvlaChangeLogbookAddressUrl: URL = URL(
        string: "https://www.gov.uk/change-address-v5c"
    )!

    public static let defaultDvlaCancelTaxUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax-refund"
    )!

    public static let defaultDvlaTaxVehicleUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax"
    )!

    public static let defaultDvlaManageTaxPaymentUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax-direct-debit/renewing"
    )!

    public static let defaultDvlaDriverDetailsUrl: URL = URL(
        string: "http://driver-and-vehicles-account.service.gov.uk/driver_details"
    )!

    public static let defaultDvlaAccountUrl: URL = URL(
        string: "http://driver-and-vehicles-account.service.gov.uk"
    )!

    public static let betaPrivacyPolicyURL: URL = {
        var components = govukBaseComponents
        components.path = """
            /government/publications/govuk-test-app-privacy-notice
            """
        return components.url!
    }()
}

extension Constants {
    public struct Timers {
        public struct Thresholds {
            public static let inactivityTimeout: TimeInterval = 15 * 60
            public static let inactivityWarning: TimeInterval = 13 * 60
        }

        public struct Animation {
            public static let chatAnimationDuration: TimeInterval = 0.20
        }
    }
}
