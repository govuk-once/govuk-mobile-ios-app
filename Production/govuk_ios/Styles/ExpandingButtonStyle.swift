import SwiftUI

struct ExpandingButtonStyle: ButtonStyle {
    let baseSize: CGFloat
    let expandedSize: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let scale = expandedSize / baseSize

        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(
                .linear(duration: 0.06),
                value: configuration.isPressed
            )
    }
}
