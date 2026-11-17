import SwiftUI
import GovKitUI
import UIKit

/// A SwiftUI wrapper around `LoadingUIButton`.
///
/// A `UIButton` is used instead of a native SwiftUI `Button` because SwiftUI swallows
/// focus updates on buttons, preventing custom focus state styling.
/// https://govukverify.atlassian.net/browse/GOVUKAPP-4351
struct LoadingButton: UIViewRepresentable {
    let viewModel: LoadingUIButton.ButtonViewModel
    let buttonConfiguration: LoadingUIButton.ButtonConfiguration

    func makeCoordinator() -> Coordinator {
        Coordinator(action: viewModel.action)
    }

    func makeUIView(context: Context) -> LoadingUIButton {
        let button = LoadingUIButton(
            viewModel: viewModel,
            configuration: buttonConfiguration
        )
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.buttonTapped),
            for: .primaryActionTriggered
        )
        return button
    }

    func updateUIView(_ uiView: LoadingUIButton, context: Context) {
        uiView.viewModel = viewModel
        context.coordinator.action = viewModel.action
    }

    final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func buttonTapped() {
            action()
        }
    }
}
