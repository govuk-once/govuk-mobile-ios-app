import SwiftUI
import GovKit

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
                .font(.govUK.largeTitleBold)
                .foregroundStyle(.primary)

            Spacer()

            if let imageResource = metadata.image {
                Image(imageResource)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 36)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            }

            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .foregroundStyle(Color(UIColor.govUK.text.link))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}
