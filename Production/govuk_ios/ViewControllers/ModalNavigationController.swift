import UIKit

final class ModalNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        applyAppearance()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyAppearance()
    }

    private func applyAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .govUK.fills.surfaceModal
        appearance.shadowColor = .clear

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance

        // extra fallback
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
    }
}
