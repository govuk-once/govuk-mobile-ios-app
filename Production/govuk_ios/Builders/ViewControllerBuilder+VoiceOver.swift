import SwiftUI
import UIKit

extension ViewControllerBuilder {
    /// Wraps a SwiftUI view in an `AccessibleHostingController` configured for VoiceOver
    /// navigation with a UIKit large title.
    ///
    /// To ensure VoiceOver announces the screen title cleanly when pushed:
    /// - **Title set in UIKit:** Avoids SwiftUI's `.navigationTitle` modifier, which propagates
    ///   preferences asynchronously after the initial layout pass and causes `UINavigationBar`
    ///   to update mid-push and interrupt VoiceOver.
    /// - **Deferred focus:** `AccessibleHostingController` waits for the push transition to
    ///   complete before posting `.screenChanged`, preventing VoiceOver from prematurely
    ///   focusing scroll view content before the large-title bar settles.
    ///
    /// - Parameters:
    ///   - rootView: The SwiftUI view to host.
    ///   - largeTitle: The localized navigation bar title.
    /// - Returns: A configured view controller ready to be pushed onto a `UINavigationController`.
    func makeVoiceOverHostingController<Content: View>(
        rootView: Content,
        largeTitle: String
    ) -> UIViewController {
        let viewController = AccessibleHostingController(rootView: rootView)
        viewController.title = largeTitle
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
}
