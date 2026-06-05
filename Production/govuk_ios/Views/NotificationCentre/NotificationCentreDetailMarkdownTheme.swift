import SwiftUI
import MarkdownUI
import GovKit

// Notification Markdown Theme
//
// Based on the existing ChatMarkdownTheme (Theme.govUK) but with a proper
// typographic heading hierarchy suited to long-form notification content.
// Chat deliberately flattens all headings to body size; notifications should
// respect H1–H4 hierarchy using the GOV.UK type scale.
//
// Usage:
//   Markdown(notification.body)
//       .markdownTheme(.govUKNotification)

extension Theme {
    public static let govUKNotification: Theme = Theme()
        // Body text
        .text {
            FontFamily(.system(.default))
            FontSize(.rem(1))       // 17pt
            ForegroundColor(Color(UIColor.govUK.text.primary))
        }
        // Links — matches existing chat theme
        .link {
            ForegroundColor(Color(UIColor.govUK.text.linkSecondary))
            UnderlineStyle(.single)
        }
        // Code blocks
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
        }
        .codeBlock { configuration in
            configuration.label
                .markdownTextStyle {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.85))
                }
                .padding(12)
                .background(Color(UIColor.govUK.fills.surfaceCardDefault))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .markdownMargin(top: .rem(1), bottom: .rem(1))
        }
        // Blockquote — 4pt left border matching Android implementation
        .blockquote { configuration in
            HStack(spacing: 0) {
                Color(UIColor.govUK.text.primary)
                    .frame(width: 4)
                configuration.label
                    .markdownTextStyle { FontStyle(.italic) }
                    .padding(12)
                    .background(Color(UIColor.govUK.fills.surfaceCardDefault))
            }
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .markdownMargin(top: .rem(1), bottom: .rem(1))
        }
        // List items — matches existing chat theme adjustment
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: .em(0.3))
                .padding(.leading, -12)
        }
        // Thematic break
        .thematicBreak {
            Divider()
                .overlay(Color(UIColor.govUK.strokes.listDivider))
                .markdownMargin(top: .rem(1.5), bottom: .rem(1.5))
        }
        // H1 — Large Title (34pt), e.g. main notification heading
        .heading1 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(0.5))
                .markdownTextStyle {
                    FontWeight(.bold)
                    FontSize(.rem(2))           // 34pt
                }
        }
        // H2 — Title 1 (28pt)
        .heading2 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(0.5))
                .markdownTextStyle {
                    FontWeight(.bold)
                    FontSize(.rem(1.65))        // ~28pt
                }
        }
        // H3 — Title 2 (22pt)
        .heading3 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.2), bottom: .rem(0.5))
                .markdownTextStyle {
                    FontWeight(.bold)
                    FontSize(.rem(1.3))         // ~22pt
                }
        }
        // H4 — Title 3 (20pt)
        .heading4 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.2), bottom: .rem(0.5))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.rem(1.18))        // ~20pt
                }
        }
        // H5 — Subheadline (15pt)
        .heading5 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1), bottom: .rem(0.5))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.rem(0.9))         // ~15pt
                }
        }
        // H6 — Caption (12pt)
        .heading6 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1), bottom: .rem(0.5))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.rem(0.7))         // ~12pt
                }
        }
}
