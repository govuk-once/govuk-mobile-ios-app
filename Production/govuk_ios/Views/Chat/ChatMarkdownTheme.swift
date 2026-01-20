import SwiftUI
import MarkdownUI
import GovKit

extension Theme {
    static let govUK: Theme = Theme.basic
        .link {
            ForegroundColor(Color(UIColor.govUK.text.linkSecondary))
            UnderlineStyle(.single)
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: .em(0.3))
                .padding(.leading, -12)
        }
        .heading1 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
        }
        .heading2 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
        }
        .heading3 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
        }
        .heading4 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
        }
        .heading5 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
        }
        .heading6 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
        }
}
