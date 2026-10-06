import SwiftUI
import GovKitUI

struct ChatFeedbackView: View {
    @ObservedObject var viewModel: ChatFeedbackViewModel
    @AccessibilityFocusState private var isConfirmationFocused: Bool
    private let animationDuration: TimeInterval = 0.3

    var body: some View {
        ZStack(alignment: .leading) {
            if viewModel.state == .confirmed {
                confirmationView
                    .transition(.opacity)
            } else {
                ratingRow
                    .transition(.opacity)
            }
        }
        .conditionalAnimation(
            .easeInOut(duration: animationDuration),
            value: viewModel.state
        )
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onReceive(viewModel.confirmationFocusRequests) {
            focusConfirmation()
        }
    }

    private var ratingRow: some View {
        HStack(spacing: 0) {
            if isThumbVisible(isPositive: true) {
                ratingButton(isPositive: true)
                    .transition(.opacity)
            }
            if isThumbVisible(isPositive: false) {
                ratingButton(isPositive: false)
                    .transition(.opacity)
            }
            if let selection = viewModel.selection, viewModel.isLinkVisible {
                surveyLink(isPositive: selection)
                    .padding(.leading, 8)
                    .transition(
                        .opacity.animation(.easeInOut(duration: animationDuration).delay(0.1))
                    )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(.Chat.feedbackGroupAccessibilityLabel))
    }

    private func isThumbVisible(isPositive: Bool) -> Bool {
        viewModel.selection == nil || viewModel.selection == isPositive
    }

    private func ratingButton(isPositive: Bool) -> some View {
        let isSelected = viewModel.selection == isPositive
        return Button {
            viewModel.rate(isPositive: isPositive)
        } label: {
            Label {
                accessibilityLabel(isPositive: isPositive)
            } icon: {
                thumbImage(isPositive: isPositive, isSelected: isSelected)
            }
            .labelStyle(.iconOnly)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .allowsHitTesting(viewModel.state == .unrated)
        .accessibilityRemoveTraits(isSelected ? .isButton : [])
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func surveyLink(isPositive: Bool) -> some View {
        Button(action: viewModel.openSurvey) {
            Text(isPositive ?
                 LocalizedStringResource.Chat.feedbackPositiveLinkTitle :
                    .Chat.feedbackNegativeLinkTitle)
                .font(.govUK.body)
                .foregroundStyle(Color(UIColor.govUK.text.linkSecondary))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 44)
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(Text(.Chat.feedbackLinkAccessibilityHint))
    }

    private var confirmationView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.govUK.body)
                .foregroundStyle(Color(UIColor.govUK.text.secondary))
                .accessibilityHidden(true)
            Text(.Chat.feedbackConfirmationTitle)
                .font(.govUK.body)
                .foregroundStyle(Color(UIColor.govUK.text.secondary))
                .accessibilityFocused($isConfirmationFocused)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
    }

    private func thumbImage(isPositive: Bool, isSelected: Bool) -> some View {
        let name = isPositive ? "hand.thumbsup" : "hand.thumbsdown"
        return ZStack {
            Image(systemName: name)
                .opacity(isSelected ? 0 : 1)
            Image(systemName: name + ".fill")
                .opacity(isSelected ? 1 : 0)
        }
        .font(.govUK.body)
        .foregroundStyle(Color(UIColor.govUK.text.secondary))
    }

    private func accessibilityLabel(isPositive: Bool) -> Text {
        Text(isPositive ?
             LocalizedStringResource.Chat.feedbackHelpfulAccessibilityLabel :
                .Chat.feedbackNotHelpfulAccessibilityLabel)
    }

    private func focusConfirmation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isConfirmationFocused = true
        }
    }
}
