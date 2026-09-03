import Foundation
import SwiftUI

struct QuarterlySurveyWidgetView: View {
    let viewModel: QuarterlySurveyWidgetViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text(.Home.quarterlySurveyWidgetTitle)
                .font(.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundColor(
                    Color(UIColor.govUK.text.primary)
                )
            HStack {
                Spacer()
                feedbackButton
                    .padding(16)
                    .background(Color(UIColor.govUK.fills.surfaceButtonPrimary))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .accessibilityElement(children: .combine)
                Spacer()
            }
        }
    }

    private var feedbackButton: some View {
        Button(
            action: {
                self.viewModel.action()
            }, label: {
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsdown.hand.thumbsup.fill")
                        .foregroundStyle(Color(uiColor: .govUK.text.buttonPrimary))
                        .fontWeight(.semibold)
                        .frame(
                            minWidth: 24,
                            minHeight: 22
                        )
                        .accessibilityHidden(true)
                    Text(.Home.quartelySurveyButtonTitle)
                        .font(.govUK.bodySemibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(
                            Color(uiColor: UIColor.govUK.text.buttonPrimary)
                        )
                }
            }
        )
    }
}
