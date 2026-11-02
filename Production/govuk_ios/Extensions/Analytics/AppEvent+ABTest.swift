import Foundation
import GovKit

extension AppEvent {
    static func abTest(_ value: ABTestAppEvent) -> AppEvent {
        .init(
            name: value.rawValue,
            params: nil
        )
    }
}

enum ABTestAppEvent: String, Codable {
    case homeActivation1026 = "ab_test_activation_home_10_26"
    case searchConversion1026 = "ab_test_conversion_search_invoked_10_26"
}
