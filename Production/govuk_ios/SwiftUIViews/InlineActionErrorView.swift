import SwiftUI
import MarkdownUI

struct InlineActionErrorView: View {
    var viewModel: InlineActionErrorViewModel

    init(viewModel: InlineActionErrorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 8) {
            warningImage
            errorTitle
            errorBody
        }
        .padding(.vertical, 32)
    }

    private var warningImage: some View {
        Image(systemName: "exclamationmark.circle")
            .resizable()
            .frame(width: 31, height: 31)
            .foregroundColor(Color(uiColor: .govUK.text.trailingIcon))
            .fontWeight(.light)
            .accessibilityHidden(true)
            .padding(.bottom, 8)
    }

    private var errorTitle: some View {
        Text(viewModel.title)
            .font(.govUK.bodySemibold)
            .multilineTextAlignment(.center)
    }

    private var errorBody: some View {
        InfoMarkdownView(
            viewModel.markdownBody,
            markdownTheme: Theme.govUK,
            openUrlAction: viewModel.openURLAction
        )
    }
}
