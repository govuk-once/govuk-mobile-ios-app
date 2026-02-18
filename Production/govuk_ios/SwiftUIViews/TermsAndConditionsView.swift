import Foundation
import SwiftUI

struct TermsAndConditionsView<Model>: View where Model: TermsAndConditionsViewModel {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject private var viewModel: Model

    init(viewModel: Model) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    contentView
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                }
                .modifier(ScrollBounceBehaviorModifier())
            }
            buttonView
        }
        .background(Color(uiColor: UIColor.govUK.fills.surfaceFullscreen))
        .navigationBarHidden(true)
    }

    private var buttonView: some View {
        ButtonStackView(
            primaryButtonViewModel: viewModel.primaryButtonViewModel,
            secondaryButtonViewModel: viewModel.secondaryButtonViewModel
        )
        .alert(
            viewModel.alertDetails.title,
            isPresented: $viewModel.showAlert,
            presenting: viewModel.alertDetails
        ) { details in
            Button(role: .cancel) {
                viewModel.showAlert = false
            } label: {
                Text(details.primaryButtonTitle)
            }
            .keyboardShortcut(.defaultAction)
            Button(role: .destructive) {
                viewModel.showAlert = false
                viewModel.alertDetails.secondaryButtonAction?()
            } label: {
                Text(details.secondaryButtonTitle ?? "")
            }
        } message: { details in
            Text(details.message)
        }
    }

    private var contentView: some View {
        VStack {
            if verticalSizeClass != .compact {
                Image(decorative: "TermsAndConditions")
                    .padding(.bottom, 16)
                    .accessibilityHidden(true)
            }

            Text(viewModel.title)
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .font(Font.govUK.largeTitleBold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 16)

            VStack(alignment: .center, spacing: 22) {
                ForEach(viewModel.linkList, id: \.text) { linkListItem in
                    linkView(
                        text: linkListItem.text,
                        url: linkListItem.url
                    )
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
    }

    private func linkView(text: String, url: URL) -> some View {
        Button(
            action: { viewModel.openURL(url) },
            label: {
                Text(text)
                    .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
                    .font(Font.govUK.body)
                    .multilineTextAlignment(.center)
            }
        )
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(String.common.localized("openWebLinkHint"))
    }
}
