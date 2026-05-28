import Foundation
import SwiftUI

struct ToolbarGlassButton: View {
    let action: () -> Void
    let label: AnyView

    init(action: @escaping () -> Void,
         @ViewBuilder label: () -> some View) {
        self.action = action
        self.label = AnyView(label())
    }

    var body: some View {
        Button(
            action: {
                action()
            }, label: {
                label
            }
        ).applyStyle {
            if #available(iOS 26.0, *) {
                $0.buttonStyle(.glass)
            } else {
                $0
            }
        }
    }
}
