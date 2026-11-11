import SwiftUI

struct CancelButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel, action: action)
                .tint(Color(uiColor: .govUK.text.primary))
        } else {
            Button(String.common.localized("cancel"), action: action)
                .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
        }
    }
}
