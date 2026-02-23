import Foundation
import SwiftUI

struct UserFeedbackWidgetView: View {
    let viewModel: UserFeedbackWidgetViewModel

    var body: some View {
        VStack(spacing: 18) {
            Text(viewModel.body)
                .font(.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundColor(
                    Color(UIColor.govUK.text.primary)
                )
            linkButton(title: viewModel.linkTitle)
        }
    }

    @ViewBuilder
    private func linkButton(title: String) -> some View {
        Button(
            action: {
                self.viewModel.open()
            }, label: {
                Text(title)
                    .font(.govUK.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        Color(uiColor: UIColor.govUK.text.buttonSecondary)
                    )
                    .frame(maxWidth: .infinity)
            }
        )
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(
            String.common.localized("openWebLinkHint")
        )
    }
}
