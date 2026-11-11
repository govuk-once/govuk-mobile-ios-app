import SwiftUI

struct FurtherInformationSectionView: View {
    let links: [CategoryLink]
    var onLinkClick: ((CategoryLink) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Further information")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(links.enumerated()), id: \.element.id) { index, link in
                    Button {
                        onLinkClick?(link)
                    } label: {
                        HStack {
                            Text(link.text)
                                .font(.body)
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)

                    if index < links.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
