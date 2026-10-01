import Foundation
import UIKit

protocol DeeplinkRoute {
    var pattern: URLPattern { get }
    var shouldSwitchTab: Bool { get }

    @MainActor
    func action(parent: BaseCoordinator,
                params: [String: String])
}

extension DeeplinkRoute {
    var shouldSwitchTab: Bool { true }
}
