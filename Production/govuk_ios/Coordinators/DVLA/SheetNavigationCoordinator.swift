import UIKit
import SwiftUI

/// A coordinator that manages a self-contained navigation stack presented modally as a sheet,
/// providing seamless integration for hosting and pushing SwiftUI views.
final class SheetNavigationCoordinator: BaseCoordinator {
    /// Creates a new sheet navigation coordinator with a root view builder.
    ///
    /// - Parameter content: A closure that builds the root SwiftUI view, receiving a reference
    ///   to the coordinator so child views can trigger navigation pushes.
    ///
    init<Content: View>(@ViewBuilder content: (SheetNavigationCoordinator) -> Content) {
            let navController = UINavigationController()
            super.init(navigationController: navController)

            let view = content(self)
            let hostingController = UIHostingController(rootView: view)
            // must use super.set so the root view controller is tracked in stackedViewControllers
            set(hostingController, animated: false)
        }

    override func start(url: URL?) {
        // No-op by default; override if deep-linking into the sheet is required.
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
