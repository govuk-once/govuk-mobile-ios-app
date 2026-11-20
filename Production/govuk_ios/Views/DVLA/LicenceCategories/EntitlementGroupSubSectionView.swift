import SwiftUI

struct EntitlementGroupSubSectionView: View {
    let group: EntitlementGroup
    var showsHighlight: Bool = true
    var onSelectRow: ((Entitlement) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SubsectionHeaderText(group.group.title)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 4)

            ForEach(group.entitlements) { entitlement in
                EntitlementRowView(
                    entitlement: entitlement,
                    showsHighlight: showsHighlight,
                    onSelect: onSelectRow.map { action in
                        { action(entitlement) }
                    }
                )

                if entitlement.id != group.entitlements.last?.id {
                    Divider()
                        .overlay(Color(.separator).opacity(0.6))
                        .padding(.horizontal, 16)
                }
            }
        }
    }
}
