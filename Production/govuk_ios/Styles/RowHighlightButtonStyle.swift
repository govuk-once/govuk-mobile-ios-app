import SwiftUI
import GovKitUI

struct RowHighlightButtonStyle: ButtonStyle {
    var showsHighlight: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                showsHighlight && configuration.isPressed
                    ? Color(.systemFill)
                    : Color.clear
            )
            .contentShape(Rectangle())
    }
}
