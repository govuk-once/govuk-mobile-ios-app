import SwiftUI
import GovKitUI

struct RowHighlightButtonStyle: ButtonStyle {
    var showsHighlight: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                showsHighlight && configuration.isPressed
                    ? Color(.systemFill)
                    : Color.clear
            )
    }
}
