import SwiftUI
import UIKit

/// A `UIHostingController` subclass that defers VoiceOver focus until a navigation push
/// completes, ensuring the navigation bar title is announced cleanly without interruption.
final class AccessibleHostingController<Content: View>: UIHostingController<Content> {
    private var focusTask: Task<Void, Never>?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMovingToParent {
            view.accessibilityElementsHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard view.accessibilityElementsHidden else { return }

        focusTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            self.view.accessibilityElementsHidden = false

            let targetTitle = self.navigationItem.title ?? self.title
            let titleElement = self.navigationController?.navigationBar
                .findAccessibilityElement(matchingLabel: targetTitle)

            UIAccessibility.post(
                notification: .screenChanged,
                argument: titleElement
            )
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        focusTask?.cancel()
        focusTask = nil
        view.accessibilityElementsHidden = false
    }
}
