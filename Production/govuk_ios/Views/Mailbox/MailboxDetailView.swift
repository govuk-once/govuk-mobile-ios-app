import SwiftUI
import GovKit
import GovKitUI

struct MailboxDetailView: View {
    @StateObject private var viewModel: MailboxDetailViewModel
    @State private var showDeleteConfirmation = false

    init(viewModel: MailboxDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.bottom, 16)

                Divider()
                    .padding(.bottom, 16)

                subjectSection
                    .padding(.bottom, 16)

                if let actionStatus = viewModel.actionStatus {
                    actionStatusBadge(for: actionStatus)
                        .padding(.bottom, 16)
                }

                bodySection
                    .padding(.bottom, 24)

                ForEach(
                    Array(viewModel.actions.enumerated()),
                    id: \.offset
                ) { _, action in
                    actionButton(for: action)
                        .padding(.bottom, 16)
                }

                deleteButton
            }
            .padding(16)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        viewModel.markAsUnopened()
                    } label: {
                        Label(
                            "Mark as unopened",
                            systemImage: "envelope.badge"
                        )
                    }
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(
                            Color(uiColor: .govUK.text.primary)
                        )
                }
            }
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
        .alert(
            "Delete message",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteMessage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This message will be permanently deleted.")
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: viewModel.senderColor))
                    .frame(width: 44, height: 44)
                Text(viewModel.senderLetter)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.senderName)
                    .font(Font.govUK.bodySemibold)
                    .foregroundStyle(
                        Color(uiColor: .govUK.text.primary)
                    )
                Text(viewModel.formattedDate)
                    .font(Font.govUK.caption1)
                    .foregroundStyle(
                        Color(uiColor: .govUK.text.secondary)
                    )
            }
        }
    }

    private var subjectSection: some View {
        Text(viewModel.subject)
            .font(Font.govUK.title3Semibold)
            .foregroundStyle(Color(uiColor: .govUK.text.primary))
    }

    private func actionStatusBadge(
        for actionStatus: ActionStatus
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: actionStatus.iconName)
                .foregroundStyle(Color(uiColor: actionStatus.color))
            Text(actionStatus.rawValue)
                .font(Font.govUK.bodySemibold)
                .foregroundStyle(Color(uiColor: actionStatus.color))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(uiColor: actionStatus.color).opacity(0.1))
        )
    }

    private var bodySection: some View {
        Text(viewModel.body)
            .font(Font.govUK.body)
            .foregroundStyle(Color(uiColor: .govUK.text.primary))
            .lineSpacing(4)
    }

    private func actionButton(for action: MessageAction) -> some View {
        Button {
            viewModel.performAction(action)
        } label: {
            HStack {
                Spacer()
                Text(actionTitle(for: action))
                    .font(Font.govUK.bodySemibold)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.vertical, 12)
            .background(
                Color(uiColor: .govUK.fills.surfaceButtonPrimary)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .accessibilityHint(accessibilityHint(for: action))
    }

    private func accessibilityHint(
        for action: MessageAction
    ) -> String {
        switch action {
        case .payment:
            return "Opens the payment page"
        case .applyInApp:
            return "Opens the DVLA section of the app"
        case .openURL:
            return "Opens in a web browser"
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Spacer()
                Image(systemName: "trash")
                Text("Delete message")
                    .font(Font.govUK.bodySemibold)
                Spacer()
            }
            .padding(.vertical, 12)
            .foregroundStyle(.red)
            .background(
                Color(uiColor: .govUK.fills.surfaceCardDefault)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func actionTitle(for action: MessageAction) -> String {
        switch action {
        case .applyInApp(let title, _):
            return title
        case .openURL(let title, _):
            return title
        case .payment(let title, _, _):
            return title
        }
    }
}

extension MailboxDetailView: TrackableScreen {
    var trackingName: String {
        "Mailbox Message Detail"
    }

    var trackingTitle: String? {
        viewModel.subject
    }
}
