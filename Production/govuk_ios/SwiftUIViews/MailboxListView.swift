import SwiftUI

struct MailboxListView: View {
    @StateObject var viewModel: MailboxViewModel
    @State private var selectedMessage: MessageListItem?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.messages.isEmpty {
                    ProgressView("Loading messages...")
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.loadMessages()
                    }
                } else if viewModel.messages.isEmpty {
                    EmptyMailboxView()
                } else {
                    messageList
                }
            }
            .navigationTitle("Your Mail")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.loadMessages()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                if viewModel.messages.isEmpty {
                    viewModel.loadMessages()
                }
            }
        }
    }

    private var messageList: some View {
        List {
            ForEach(viewModel.messages) { message in
                NavigationLink(
                    destination: MessageDetailView(
                        viewModel: MessageDetailViewModel(
                            serviceClient: MailboxServiceClient(),
                            token: viewModel.token,
                            messageId: message.messageId
                        )
                    )
                ) {
                    MessageRowView(message: message)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteMessage(messageId: message.messageId)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        viewModel.archiveMessage(messageId: message.messageId)
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tint(.blue)
                }
            }

            if viewModel.hasMoreMessages {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button("Load More") {
                            viewModel.loadMoreMessages()
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .refreshable {
            viewModel.loadMessages()
        }
    }
}

struct MessageRowView: View {
    let message: MessageListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let date = message.receivedDate {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(message.subject)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyMailboxView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No messages")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Messages from government departments will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: MailboxError
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Unable to load messages")
                .font(.title2)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retry) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct MailboxListView_Previews: PreviewProvider {
    static var previews: some View {
        MailboxListView(
            viewModel: MailboxViewModel(
                serviceClient: MockMailboxServiceClient(),
                token: "preview_token"
            )
        )
    }
}

class MockMailboxServiceClient: MailboxServiceClientInterface {
    func createMailbox(token: String, completion: @escaping (Result<CreateMailboxResponse, MailboxError>) -> Void) {
        completion(.success(CreateMailboxResponse(
            mailboxId: "preview-mailbox",
            authSystemSub: "preview-sub",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )))
    }

    func listMessages(token: String, limit: Int?, nextToken: String?, completion: @escaping (Result<ListMessagesResponse, MailboxError>) -> Void) {
        let messages = [
            MessageListItem(
                messageId: "1",
                mailboxId: "preview",
                receivedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                subject: "Action required: Upload your fit note",
                sender: "Department for Work and Pensions"
            ),
            MessageListItem(
                messageId: "2",
                mailboxId: "preview",
                receivedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                subject: "Your vehicle tax is due",
                sender: "Driver and Vehicle Licensing Agency"
            )
        ]
        completion(.success(ListMessagesResponse(messages: messages, nextToken: nil)))
    }

    func getMessage(token: String, messageId: String, completion: @escaping (Result<MessageDetail, MailboxError>) -> Void) {
        completion(.success(MessageDetail(
            messageId: messageId,
            mailboxId: "preview",
            receivedAt: ISO8601DateFormatter().string(from: Date()),
            subject: "Test Message",
            sender: "Test Department",
            body: "This is a test message body.",
            serviceName: "Test Service",
            messageType: "Update",
            primaryAction: nil,
            deadline: nil,
            secondaryAction: nil
        )))
    }

    func markAsRead(token: String, messageId: String, readAt: Date, completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void) {
        completion(.success(UpdateMessageResponse(success: true)))
    }

    func markAsUnread(token: String, messageId: String, completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void) {
        completion(.success(UpdateMessageResponse(success: true)))
    }

    func archiveMessage(token: String, messageId: String, archived: Bool, completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void) {
        completion(.success(UpdateMessageResponse(success: true)))
    }

    func deleteMessage(token: String, messageId: String, completion: @escaping (Result<Void, MailboxError>) -> Void) {
        completion(.success(()))
    }

    func grantConsent(token: String, departmentId: String, departmentPersonId: String, completion: @escaping (Result<GrantConsentResponse, MailboxError>) -> Void) {
        completion(.success(GrantConsentResponse(
            mailboxId: "preview",
            departmentId: departmentId,
            departmentPersonId: departmentPersonId,
            consentedAt: ISO8601DateFormatter().string(from: Date())
        )))
    }
}
#endif
