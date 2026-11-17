import SwiftUI
import MarkdownUI

struct MarkdownWithAccessibleLinks: View {
    let markdownContent: String
    let onLinkTapped: (URL) -> Void

    init(_ markdownContent: String, onLinkTapped: @escaping (URL) -> Void) {
        self.markdownContent = markdownContent
        self.onLinkTapped = onLinkTapped
    }

    private var components: [MarkdownLinkParser.Component] {
        MarkdownLinkParser().parse(markdownContent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                switch component {
                case .text(let text):
                    Markdown(text)
                        .markdownTheme(.govUKNotification)
                case .link(let text, let urlString):
                    if let url = URL(string: urlString) {
                        AccessibleLink(
                            text: text,
                            url: url,
                            isFirst: index == 0,
                            isBulletItem: false,
                            onTapped: onLinkTapped
                        )
                    }
                case .bulletLink(let text, let urlString):
                    if let url = URL(string: urlString) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("•")
                                .font(Font.govUK.title2Bold)
                                .foregroundColor(Color(UIColor.govUK.text.primary))
                            AccessibleLink(
                                text: text,
                                url: url,
                                isFirst: index == 0,
                                isBulletItem: true,
                                onTapped: onLinkTapped
                            )
                        }
                        .padding(.leading, 5)
                    }
                }
            }
        }
    }
}

private struct AccessibleLink: View {
    let text: String
    let url: URL
    let isFirst: Bool
    let isBulletItem: Bool
    let onTapped: (URL) -> Void

    private var isExternalLink: Bool {
        url.isExternalWebLink
    }

    var body: some View {
        Button {
            onTapped(url)
        } label: {
            Text(text)
                .font(Font.govUK.body)
                .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
                .underline()
                .padding(.vertical, 13)
        }
        .padding(.top, isBulletItem ? 0 : (isFirst ? 0 : 24))
        .padding(.bottom, isBulletItem ? 0 : 24)
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityHint(isExternalLink ? String.common.localized("openWebLinkHint") : "")
        .accessibilityAddTraits(.isLink)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 24) {
        MarkdownWithAccessibleLinks(
            "This is a [link](https://www.gov.uk) in markdown",
            onLinkTapped: { _ in }
        )
        MarkdownWithAccessibleLinks(
            "More information:\n\n* [GOV.UK homepage](https://www.gov.uk)\n* [Contact us](https://www.gov.uk/contact)",
            onLinkTapped: { _ in }
        )
    }
    .padding()
}
#endif
