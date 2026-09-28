import SwiftUI
import GovKitUI

struct ChatFeedbackView: View {
    @ObservedObject var viewModel: ChatFeedbackViewModel
    @AccessibilityFocusState private var isLinkFocused: Bool
    @AccessibilityFocusState private var isConfirmationFocused: Bool
    private let announcementDelay: Duration = .seconds(1)

    var body: some View {
        Group {
            switch viewModel.state {
            case .unrated:
                ratingButtons
            case .rated(let isPositive), .surveyOpened(let isPositive):
                selectedView(isPositive: isPositive)
            case .confirmed:
                confirmationView
            }
        }
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: viewModel.state) { state in
            announce(state)
        }
    }

    private var ratingButtons: some View {
        HStack(spacing: 0) {
            ratingButton(isPositive: true)
            ratingButton(isPositive: false)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(.Chat.feedbackGroupAccessibilityLabel))
    }

    private func ratingButton(isPositive: Bool) -> some View {
        Button {
            viewModel.rate(isPositive: isPositive)
        } label: {
            Label {
                accessibilityLabel(isPositive: isPositive)
            } icon: {
                thumbImage(isPositive: isPositive, isSelected: false)
            }
            .labelStyle(.iconOnly)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
    }

    private func selectedView(isPositive: Bool) -> some View {
        HStack(spacing: 8) {
            thumbImage(isPositive: isPositive, isSelected: true)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel(accessibilityLabel(isPositive: isPositive))
                .accessibilityAddTraits(.isSelected)
            if viewModel.isLinkVisible {
                surveyLink(isPositive: isPositive)
            }
        }
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
        .accessibilityFocused($isLinkFocused)
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
        return Image(systemName: isSelected ? name + ".fill" : name)
            .font(.govUK.body)
            .foregroundStyle(
                Color(isSelected ? UIColor.govUK.text.primary : UIColor.govUK.text.secondary)
            )
    }

    private func accessibilityLabel(isPositive: Bool) -> Text {
        Text(isPositive ?
             LocalizedStringResource.Chat.feedbackHelpfulAccessibilityLabel :
                .Chat.feedbackNotHelpfulAccessibilityLabel)
    }

    private func announce(_ state: ChatFeedbackState) {
        switch state {
        case .rated(let isPositive):
            post(
                announcement: isPositive ?
                    LocalizedStringResource.Chat.feedbackHelpfulSelectedAccessibilityAnnouncement :
                    .Chat.feedbackNotHelpfulSelectedAccessibilityAnnouncement,
                thenFocus: { isLinkFocused = viewModel.isLinkVisible }
            )
        case .confirmed:
            post(
                announcement: .Chat.feedbackConfirmationTitle,
                thenFocus: { isConfirmationFocused = true }
            )
        case .unrated, .surveyOpened:
            break
        }
    }

    private func post(announcement: LocalizedStringResource,
                      thenFocus focus: @escaping () -> Void) {
        UIAccessibility.post(
            notification: .announcement,
            argument: String(localized: announcement)
        )
        Task { @MainActor in
            try? await Task.sleep(for: announcementDelay)
            focus()
        }
    }
}
