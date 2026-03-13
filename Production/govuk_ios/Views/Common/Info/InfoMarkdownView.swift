import SwiftUI
import MarkdownUI

struct InfoMarkdownView: View {
    private let markdownText: String
    private let markdownTheme: Theme
    private let openUrlAction: (URL) -> Void

    init(_ markdownText: String,
         markdownTheme: Theme = .basic,
         openUrlAction: @escaping (URL) -> Void) {
        self.markdownText = markdownText
        self.markdownTheme = markdownTheme
        self.openUrlAction = openUrlAction
    }
    var body: some View {
        Markdown(markdownText)
            .markdownTheme(markdownTheme)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .environment(\.openURL, OpenURLAction { url in
                openUrlAction(url)
                return .handled
            })
            .padding(.horizontal, 16)
    }
}
