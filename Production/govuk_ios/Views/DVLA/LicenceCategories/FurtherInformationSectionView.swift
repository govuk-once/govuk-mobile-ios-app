import SwiftUI
import GovKit

struct FurtherInformationSectionView: View {
    let links: [CategoryLink]
    var onLinkClick: ((CategoryLink) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderText("Further information")

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(links.enumerated()), id: \.element.id) { index, link in
                    Button {
                        onLinkClick?(link)
                    } label: {
                        HStack {
                            Text(link.text)
                                .font(.body)
                                .foregroundStyle(
                                    Color(UIColor.govUK.text.link)
                                )
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)

                    if index < links.count - 1 {
                        Divider()
                            .foregroundStyle(Color(uiColor: .govUK.strokes.listDivider))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.govUK.fills.surfaceListAlt))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
