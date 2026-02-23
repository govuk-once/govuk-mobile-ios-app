import SwiftUI

struct ChatMenuView: View {
    private var viewModel: ChatViewModel
    private var menuDimensions: CGSize
    @Binding var showClearChatAlert: Bool
    @Binding var disableClearChat: Bool

    init(viewModel: ChatViewModel,
         menuDimensions: CGSize,
         showClearChatAlert: Binding<Bool>,
         disableClearChat: Binding<Bool>) {
        self.viewModel = viewModel
        self.menuDimensions = menuDimensions
        _showClearChatAlert = showClearChatAlert
        _disableClearChat = disableClearChat
    }

    var body: some View {
        Menu {
            if viewModel.currentConversationExists {
                Button(
                    role: .destructive,
                    action: {
                        viewModel.trackMenuClearChatTap()
                        showClearChatAlert = true
                    },
                    label: {
                        Label(.Chat.clearMenuTitle,
                              systemImage: "trash")
                    }
                )
                .disabled(disableClearChat)
            }
            Button(
                action: { viewModel.openPrivacyURL() },
                label: {
                    Text(.Chat.privacyMenuTitle)
                        .accessibilityLabel(.Chat.optInPrivacyLinkTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openAboutURL() },
                label: {
                    Text(.Chat.aboutMenuTitle)
                        .accessibilityLabel(.Chat.aboutMenuAccessibilityTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openFeedbackURL() },
                label: {
                    Text(.Chat.feedbackMenuTitle)
                        .accessibilityLabel(.Chat.feedbackMenuAccessibilityTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(UIColor.govUK.text.buttonSecondary))
                .frame(width: menuDimensions.width, height: menuDimensions.height)
                .background(
                    Circle()
                        .fill(Color(UIColor.govUK.fills.surfaceChatAction))
                )
        }
        .accessibilityLabel(.Chat.moreOptionsAccessibilityLabel)
        .accessibilitySortPriority(0)
    }
}
