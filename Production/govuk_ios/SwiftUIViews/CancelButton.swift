import SwiftUI

/// A toolbar cancel button. On iOS 26 and later the system renders the
/// cancel role as the standard close glyph; earlier versions show the
/// localised "Cancel" text.
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
