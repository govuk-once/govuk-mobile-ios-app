import SwiftUI

struct EntitlementMajorSectionView: View {
    let title: String
    let groups: [EntitlementGroup]
    var showsHighlight: Bool = true
    var onSelectRow: ((Entitlement) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            ForEach(groups) { group in
                EntitlementGroupSubSectionView(
                    group: group,
                    showsHighlight: showsHighlight,
                    onSelectRow: onSelectRow
                )
            }
        }
    }
}
