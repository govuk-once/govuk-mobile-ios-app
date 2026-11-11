import SwiftUI

struct EntitlementRowContentView: View {
    let metadata: LicenceCategoryDisplayMetadata

    init(metadata: LicenceCategoryDisplayMetadata) {
        self.metadata = metadata
    }

    init(entitlement: Entitlement) {
        self.metadata = LicenceCategoryDisplayMetadataBuilder.metadata(
            for: entitlement.categoryCode
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(metadata.displayName)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            Spacer()

            if let imageResource = metadata.image {
                Image(imageResource)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            }

            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundStyle(.blue)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}
