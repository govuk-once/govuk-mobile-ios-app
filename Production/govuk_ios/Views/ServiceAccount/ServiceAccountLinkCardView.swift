import SwiftUI
import GovKitUI

struct ServiceAccountLinkCardView: View {
    private let viewModel: ServiceAccountLinkCardViewModel

    init(viewModel: ServiceAccountLinkCardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button(action: {
            viewModel.action()
        },
        label: {
            ViewThatFits(in: .horizontal) {
                HStack {
                    leadingContent
                    trailingContent
                }
                HStack {
                    trailingContent
                }
            }
            .padding(16)
        })
        .buttonStyle(
            HighlightingButtonStyle(
                normalColour: Color(uiColor: .govUK.fills.surfaceCardLinkAccount),
                highlightColour: Color(uiColor: .govUK.fills.surfaceCardLinkAccountHighlight)
            )
        )
        .roundedBorder(cornerRadius: 16, borderColor: .clear)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var leadingContent: some View {
        Image(systemName: "link")
            .font(.system(size: 19))
            .foregroundStyle(Color(uiColor: .govUK.text.linkAccountCard))
        Spacer()
            .frame(width: 14)
    }

    @ViewBuilder
    private var trailingContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(Font.govUK.bodySemibold)
                .foregroundStyle(Color(uiColor: .govUK.text.linkAccountCard))
                .multilineTextAlignment(.leading)
            Text(viewModel.subtitle)
                .font(Font.govUK.body)
                .foregroundStyle(Color(uiColor: .govUK.text.linkAccountCard))
                .multilineTextAlignment(.leading)
        }
        .frame(minWidth: 275, alignment: .leading)
        Spacer()
        Image(systemName: "chevron.right")
            .font(Font.govUK.bodySemibold)
            .foregroundStyle(Color(uiColor: .govUK.text.linkAccountCard))
            .accessibilityHidden(true)
    }
}

#Preview {
    let modelOne = ServiceAccountLinkCardViewModel(
        title: "Card title",
        subtitle: "Card subtitle",
        action: { print("Tap 1") }
    )
    let modelTwo = ServiceAccountLinkCardViewModel(
        title: "Card title",
        subtitle: "Card secondary text that may go over multiple lines.",
        action: { print("Tap 2") }
    )
    ZStack {
        Color(uiColor: .govUK.fills.surfaceBackground)
        VStack(spacing: 16) {
            ServiceAccountLinkCardView(viewModel: modelOne)
            ServiceAccountLinkCardView(viewModel: modelTwo)
        }
        .padding(.horizontal)
    }
}
