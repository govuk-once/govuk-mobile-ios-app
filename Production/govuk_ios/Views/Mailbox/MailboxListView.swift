import SwiftUI
import GovKit
import GovKitUI

struct MailboxListView: View {
    @StateObject private var viewModel: MailboxListViewModel

    init(viewModel: MailboxListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .govUK.fills.surfaceBackground)
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading messages")
            } else if viewModel.messages.isEmpty {
                emptyState
            } else {
                messageList
            }
        }
        .onAppear {
            viewModel.loadMessages()
            viewModel.trackScreen(screen: self)
        }
    }

    private var messageList: some View {
        ScrollView {
            VStack(spacing: 0) {
                filterChips
                    .padding(.bottom, 8)

                if viewModel.hasMessages {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredMessages) { message in
                            MailboxMessageRow(message: message) {
                                viewModel.selectMessage(message)
                            }
                            .contextMenu {
                                if message.status == .opened {
                                    Button {
                                        viewModel.markAsUnopened(message)
                                    } label: {
                                        Label(
                                            "Mark as unopened",
                                            systemImage: "envelope.badge"
                                        )
                                    }
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteMessage(message)
                                } label: {
                                    Label(
                                        "Delete",
                                        systemImage: "trash"
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                } else {
                    filteredEmptyState
                        .padding(.top, 48)
                }
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedSenderFilter == nil,
                    action: { viewModel.setFilter(nil) }
                )

                ForEach(MessageSender.allCases, id: \.self) { sender in
                    FilterChip(
                        title: sender.rawValue,
                        isSelected: viewModel.selectedSenderFilter == sender,
                        action: { viewModel.setFilter(sender) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Color(uiColor: .govUK.text.secondary))

            Text("No messages yet")
                .font(Font.govUK.title3Semibold)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))

            Text("Messages from government services will appear here")
                .font(Font.govUK.body)
                .foregroundStyle(Color(uiColor: .govUK.text.secondary))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var filteredEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.open")
                .font(.system(size: 36))
                .foregroundStyle(Color(uiColor: .govUK.text.secondary))

            Text("No messages from this sender")
                .font(Font.govUK.body)
                .foregroundStyle(Color(uiColor: .govUK.text.secondary))

            Button("Show all messages") {
                viewModel.setFilter(nil)
            }
            .font(Font.govUK.bodySemibold)
            .foregroundStyle(Color(uiColor: .govUK.text.link))
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.govUK.caption1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color(uiColor: .govUK.fills.surfaceButtonPrimary)
                        : Color(uiColor: .govUK.fills.surfaceCardDefault)
                )
                .foregroundStyle(
                    isSelected
                        ? Color.white
                        : Color(uiColor: .govUK.text.primary)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected
                                ? Color.clear
                                : Color(uiColor: .govUK.strokes.cardDefault),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension MailboxListView: TrackableScreen {
    var trackingName: String {
        "Mailbox"
    }

    var trackingTitle: String? {
        "Mailbox"
    }
}
