import SwiftUI

struct EntitlementRowView: View {
    let entitlement: Entitlement
    var showsHighlight: Bool = true
    var onSelect: (() -> Void)?

    private var metadata: LicenceCategoryDisplayMetadata {
        LicenceCategoryDisplayMetadataBuilder.metadata(for: entitlement.categoryCode)
    }

    var body: some View {
        Group {
            if let onSelect {
                Button(action: onSelect) {
                    EntitlementRowContentView(metadata: metadata)
                }
                .buttonStyle(RowHighlightButtonStyle(showsHighlight: showsHighlight))
            } else {
                EntitlementRowContentView(metadata: metadata)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Category \(metadata.displayName)")
    }
}
