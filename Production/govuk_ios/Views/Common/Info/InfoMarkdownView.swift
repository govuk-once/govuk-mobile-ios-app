import SwiftUI
import MarkdownUI

struct InfoMarkdownView: View {
    private let markdownText: String
    private let openUrlAction: (URL) -> Void

    init(_ markdownText: String,
         openUrlAction: @escaping (URL) -> Void) {
        self.markdownText = markdownText
        self.openUrlAction = openUrlAction
    }
    var body: some View {
        Markdown(markdownText)
            .fixedSize(horizontal: false, vertical: true)
            .markdownTheme(Theme.basic
                .link {
                    ForegroundColor(Color(UIColor.govUK.text.linkSecondary))
                })
            .multilineTextAlignment(.center)
            .environment(\.openURL, OpenURLAction { url in
                openUrlAction(url)
                return .handled
            })
            .padding(.horizontal, 16)
    }
}
