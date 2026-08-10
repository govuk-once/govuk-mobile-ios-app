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

            if viewModel.isLoading && viewModel.messages.isEmpty && viewModel.loadError == nil {
                ProgressView()
                    .accessibilityLabel("Loading messages")
            } else if let loadError = viewModel.loadError {
                errorState(loadError)
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
        VStack(spacing: 0) {
            if viewModel.refreshFailed {
                refreshErrorBanner
            }
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MailboxMessageRow(message: message) {
                            viewModel.selectMessage(message)
                        }
                        .contextMenu {
                            if !message.isUnopened {
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
            }
            .refreshable {
                await viewModel.refreshMessages()
            }
        }
    }

    private var refreshErrorBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(Color(uiColor: .govUK.text.trailingIcon))
                .accessibilityHidden(true)
            Text("Couldn't refresh messages")
                .font(Font.govUK.body)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(uiColor: .govUK.fills.surfaceCardDefault))
        .accessibilityElement(children: .combine)
    }

    private func errorState(_ errorViewModel: InlineActionErrorViewModel) -> some View {
        ScrollView {
            InlineActionErrorView(viewModel: errorViewModel)
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color(uiColor: .govUK.fills.surfaceList))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
                .padding(.top, 16)
        }
        .refreshable {
            await viewModel.refreshMessages()
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
}

extension MailboxListView: TrackableScreen {
    var trackingName: String {
        "Mailbox"
    }

    var trackingTitle: String? {
        "Mailbox"
    }
}
