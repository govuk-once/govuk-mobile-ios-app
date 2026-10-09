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
                    Image("quarterly_survey_icon")
                        .frame(width: 24, height: 22)
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
