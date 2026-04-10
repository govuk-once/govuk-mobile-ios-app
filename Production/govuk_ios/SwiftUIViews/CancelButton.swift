import SwiftUI

struct CancelButton: View {
    let action: () -> Void
    var body: some View {
        if #available(iOS 26.0, *) {
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
            ).buttonStyle(.glass)
        } else {
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
            )
        }
    }
}

