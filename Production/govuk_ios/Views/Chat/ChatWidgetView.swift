import SwiftUI
import GovKitUI

struct ChatWidgetView: View {
    let viewModel: ChatWidgetViewModel

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    title
                    subtitle
                }
                Spacer(minLength: 16)
                dismissView
            }
            .padding(.leading, 16)
            Divider()
                .overlay(Color(UIColor.govUK.strokes.listDivider))
                .padding(.top, 16)
            linkButton
        }
        .background(Color(uiColor: UIColor.govUK.fills.surfaceList))
        .roundedBorder(borderColor: .clear)
    }

    private var title: some View {
        Text(viewModel.title)
            .foregroundColor(Color(UIColor.govUK.text.primary))
            .font(Font.govUK.title2Bold)
            .multilineTextAlignment(.leading)
            .accessibilityAddTraits(.isHeader)
            .accessibilitySortPriority(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private var subtitle: some View {
        Text(viewModel.body)
            .font(Font.govUK.body)
            .foregroundColor(Color(UIColor.govUK.text.primary))
            .multilineTextAlignment(.leading)
            .accessibilitySortPriority(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var dismissView: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                Image(decorative: "chat_widget")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 124)
                Spacer()
            }
            VStack(spacing: 0) {
                Button {
                    withAnimation {
                        viewModel.dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.govUK.bodySemibold)
                        .foregroundColor(Color(UIColor.govUK.text.primary))
                        .frame(width: 44, height: 44)
                        .accessibilitySortPriority(0)
                }
                .accessibilityLabel(
                    String.chat.localized("dismissChatBannerAccessibilityLabel")
                )
                Spacer()
            }
        }
    }

    private var linkButton: some View {
        Button {
            viewModel.open()
        } label: {
            HStack {
                Text(viewModel.linkTitle)
                    .font(Font.govUK.body)
                    .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
                    .multilineTextAlignment(.leading)
                    .accessibilityAddTraits(.isLink)
                    .accessibilitySortPriority(1)

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
                    .font(Font.govUK.bodySemibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .accessibilityElement(children: .combine)
        }
    }
}
