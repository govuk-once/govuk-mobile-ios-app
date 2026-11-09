import UIKit
import SwiftUI

/// A coordinator that manages a self-contained navigation stack presented modally as a sheet.
///
/// Subclasses override `start(url:)` to set the root view controller via a builder,
/// matching the established coordinator pattern in the codebase.
class SheetNavigationCoordinator: BaseCoordinator {
    init() {
        let navController = UINavigationController()
        super.init(navigationController: navController)
    }

    override func start(url: URL?) {
        // Subclasses override to set the root view controller via the builder.
    }

    /// Pushes a new SwiftUI view onto the sheet's navigation stack.
    ///
    /// - Parameters:
    ///   - view: The SwiftUI view to push.
    ///   - animated: Whether the push transition should be animated.
    func push<Content: View>(_ view: Content, animated: Bool = true) {
        let hostingController = UIHostingController(rootView: view)
        super.push(hostingController, animated: animated)
    }
}
