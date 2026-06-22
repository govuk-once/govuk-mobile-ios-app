import SwiftUI
import GovKitUI

struct UnlinkAccountsErrorView: View {
    var viewModel: UnlinkAccountsErrorViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 107, height: 107)
                    .foregroundColor(Color(uiColor: .govUK.text.primary))
                    .accessibilityHidden(true)
                VStack(spacing: 12) {
                    Text(viewModel.title)
                        .font(Font.govUK.largeTitleBold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(viewModel.description)
                        .font(Font.govUK.body)
                        .foregroundColor(Color(uiColor: .govUK.text.primary))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 8 : 32)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 16)
            Spacer()
            primaryButtonView
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var primaryButtonView: some View {
        SwiftUIButton(
            .primary,
            viewModel: viewModel.primaryButtonViewModel
        )
        .frame(minHeight: 44, idealHeight: 44)
    }
}
