import SwiftUI
import Foundation
import GovKitUI

struct LocalWasteAddressPillView: View {
    let addressString: String

    private var accessibilityString: String {
        let format = String.localWaste.localized(
            "localWasteWidgetViewAddressAccessibilityLabelFormat"
        )
        return String(format: format, addressString)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(.localLocationIcon)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .padding(.vertical, 8)
            Text(addressString)
                .padding(.vertical, 8)
                .padding(.trailing, 16)
                .font(Font.govUK.footnote)
                .foregroundColor(Color(UIColor.govUK.text.header))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.govUK.fills.textIconSurroundPrimary)))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityString)
    }
}
