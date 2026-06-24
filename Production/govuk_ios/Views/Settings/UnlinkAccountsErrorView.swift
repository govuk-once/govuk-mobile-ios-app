import SwiftUI
import GovKitUI

struct UnlinkAccountsErrorView: View {
    @ObservedObject var viewModel: UnlinkAccountsErrorViewModel
    @Environment(\.dismiss) private var dismiss
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
                        .foregroundColor(Color(uiColor: .govUK.text.primary))
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
                .onTapGesture { dismiss() }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }.background(Color(uiColor: .govUK.fills.surfaceBackground).ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: viewModel.shouldCallDismiss) { newValue in
            if newValue == true {
                dismiss()
            }
        }
    }

    private var primaryButtonView: some View {
        SwiftUIButton(
            .primary,
            viewModel: viewModel.primaryButtonViewModel
        )
        .frame(minHeight: 44, idealHeight: 44)
    }
}
