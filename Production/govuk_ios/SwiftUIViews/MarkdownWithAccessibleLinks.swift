import SwiftUI
import MarkdownUI

struct MarkdownWithAccessibleLinks: View {
    let markdownContent: String
    let onLinkTapped: (URL) -> Void

    private enum Component {
        case text(String)
        case link(String, String)
    }

    init(_ markdownContent: String, onLinkTapped: @escaping (URL) -> Void) {
        self.markdownContent = markdownContent
        self.onLinkTapped = onLinkTapped
    }

    private var components: [Component] {
        Self.parseMarkdownLinks(markdownContent)
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
                            onTapped: onLinkTapped
                        )
                    }
                }
            }
        }
    }

    private static func parseMarkdownLinks(
        _ content: String
    ) -> [Component] {
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)"
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: []
        ) else {
            return [.text(content)]
        }

        var components: [Component] = []
        var lastEnd = content.startIndex

        let matches = regex.matches(
            in: content,
            options: [],
            range: NSRange(content.startIndex..., in: content)
        )

        for match in matches {
            guard
                let fullRange = Range(match.range, in: content),
                let textRange = Range(match.range(at: 1), in: content),
                let urlRange = Range(match.range(at: 2), in: content)
            else { continue }

            if lastEnd < fullRange.lowerBound {
                components.append(.text(String(content[lastEnd..<fullRange.lowerBound])))
            }

            components.append(.link(String(content[textRange]), String(content[urlRange])))
            lastEnd = fullRange.upperBound
        }

        if lastEnd < content.endIndex {
            components.append(.text(String(content[lastEnd...])))
        }

        return components.isEmpty ? [.text(content)] : components
    }
}

private struct AccessibleLink: View {
    let text: String
    let url: URL
    let isFirst: Bool
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
                .padding(.top, isFirst ? 11 : 48)
                .padding(.bottom, 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityHint(isExternalLink ? String.common.localized("openWebLinkHint") : "")
        .accessibilityAddTraits(.isLink)
    }
}

#if DEBUG
#Preview {
    MarkdownWithAccessibleLinks(
        "This is a [link](https://www.gov.uk) in markdown",
        onLinkTapped: { _ in }
    )
}
#endif
