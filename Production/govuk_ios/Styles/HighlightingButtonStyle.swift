import SwiftUI

struct HighlightingButtonStyle: ButtonStyle {
    let normalColour: Color
    let highlightColour: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? highlightColour : normalColour)
    }
}
