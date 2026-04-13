import SwiftUI

struct CancelButton: View {
    let action: () -> Void
    var body: some View {
            Button(
                action: {
                    action()
                }, label: {
                    Text(String.common.localized("cancel"))
                        .foregroundColor(
                            Color(UIColor.govUK.text.linkSecondary)
                        )
                        .font(Font.govUK.subheadlineSemibold)
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
