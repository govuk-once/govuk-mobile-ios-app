import Foundation

struct MarkdownLinkParser {
    enum Component {
        case text(String)
        case link(String, String)
        case bulletLink(String, String, topSpacing: CGFloat, bottomSpacing: CGFloat)
    }

    private static let linkRegex = /\[([^\]]+)\]\(([^)]+)\)/
    private static let bulletMarkerRegex = /(?:\n|\A)[\t ]*[*\-][\t ]+$/

    func parse(_ content: String) -> [Component] {
        var components: [Component] = []
        var lastEnd = content.startIndex

        // Find matches natively using Swift's String search
        let matches = content.matches(of: Self.linkRegex)

        for match in matches {
            let fullRange = match.range
            let linkText = String(match.output.1)
            let urlString = String(match.output.2)

            let prefixText = String(content[lastEnd..<fullRange.lowerBound])

            if let bulletComponent = processBulletLink(
                prefixText: prefixText,
                linkText: linkText,
                urlString: urlString,
                existingComponents: components
            ) {
                components.append(contentsOf: bulletComponent)
            } else {
                if !prefixText.isEmpty {
                    components.append(.text(prefixText))
                }
                components.append(.link(linkText, urlString))
            }

            lastEnd = fullRange.upperBound
        }

        // Append remaining text trailing the last match
        if lastEnd < content.endIndex {
            components.append(.text(String(content[lastEnd...])))
        }

        guard !components.isEmpty else { return [.text(content)] }
        return applyBottomSpacing(to: components)
    }

    private func processBulletLink(
        prefixText: String,
        linkText: String,
        urlString: String,
        existingComponents: [Component]
    ) -> [Component]? {
        guard let bulletMatch = prefixText.firstMatch(of: Self.bulletMarkerRegex) else {
            return nil
        }

        let rawBeforeBullet = prefixText[..<bulletMatch.range.lowerBound]
        let trimmedBeforeBullet = rawBeforeBullet.trimmingCharacters(in: .whitespacesAndNewlines)

        let topSpacing = calculateTopSpacing(
            trimmedText: trimmedBeforeBullet,
            hasExistingComponents: !existingComponents.isEmpty
        )

        var result: [Component] = []
        if !trimmedBeforeBullet.isEmpty {
            result.append(.text(trimmedBeforeBullet))
        }
        result.append(.bulletLink(linkText, urlString, topSpacing: topSpacing, bottomSpacing: 0))
        return result
    }

    private func calculateTopSpacing(trimmedText: String, hasExistingComponents: Bool) -> CGFloat {
        if !trimmedText.isEmpty {
            return 16
        } else if hasExistingComponents {
            return 5
        } else {
            return 0
        }
    }

    private func applyBottomSpacing(to components: [Component]) -> [Component] {
        components.enumerated().map { (index, component) in
            guard case .bulletLink(let text, let url, let top, _) = component else {
                return component
            }

            // Upcoming component safety check
            let hasNextTextComponent: Bool
            if index + 1 < components.count, case .text = components[index + 1] {
                hasNextTextComponent = true
            } else {
                hasNextTextComponent = false
            }

            let bottom: CGFloat = hasNextTextComponent ? 16 : 0
            return .bulletLink(text, url, topSpacing: top, bottomSpacing: bottom)
        }
    }
}
