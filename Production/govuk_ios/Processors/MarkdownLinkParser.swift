import Foundation

struct MarkdownLinkParser {
    enum Component {
        case text(String)
        case link(String, String)
        case bulletLink(String, String)
    }

    func parse(_ content: String) -> [Component] {
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
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

            let linkText = String(content[textRange])
            let urlString = String(content[urlRange])
            let prefixText = String(content[lastEnd..<fullRange.lowerBound])

            if let bulletMatch = Self.bulletMarkerRegex?.firstMatch(
                in: prefixText,
                range: NSRange(prefixText.startIndex..., in: prefixText)
            ), let bulletRange = Range(bulletMatch.range, in: prefixText) {
                let textBeforeBullet = String(prefixText[..<bulletRange.lowerBound])
                if !textBeforeBullet.isEmpty {
                    components.append(.text(textBeforeBullet))
                }
                components.append(.bulletLink(linkText, urlString))
            } else {
                if !prefixText.isEmpty {
                    components.append(.text(prefixText))
                }
                components.append(.link(linkText, urlString))
            }

            lastEnd = fullRange.upperBound
        }

        if lastEnd < content.endIndex {
            components.append(.text(String(content[lastEnd...])))
        }

        return components.isEmpty ? [.text(content)] : components
    }

    private static let bulletMarkerRegex = try? NSRegularExpression(
        pattern: "(?:\\n|\\A)[\\t ]*[*\\-][\\t ]+$",
        options: []
    )
}
