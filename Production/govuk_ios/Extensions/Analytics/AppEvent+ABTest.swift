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
    // Example event, example_app_event will match event name in Firebase's Remote Config
    case exampleAppEvent = "example_app_event"
}
