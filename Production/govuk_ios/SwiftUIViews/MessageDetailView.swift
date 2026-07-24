import SwiftUI

struct MessageDetailView: View {
    @StateObject var viewModel: MessageDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingArchiveAlert = false

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading message...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    viewModel.loadMessage()
                }
            } else if let message = viewModel.message {
                messageContent(message)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingArchiveAlert = true
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Message", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteMessage { success in
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this message? This cannot be undone.")
        }
        .alert("Archive Message", isPresented: $showingArchiveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Archive") {
                viewModel.archiveMessage { success in
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Archive this message? You can find archived messages in your archive folder.")
        }
        .onAppear {
            if viewModel.message == nil {
                viewModel.loadMessage()
            }
        }
    }

    @ViewBuilder
    private func messageContent(_ message: MessageDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    Text(message.sender)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(message.subject)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        if let date = message.receivedDate {
                            Label {
                                Text(date, style: .date)
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))

                Divider()

                // Message type badge (if available)
                if let messageType = message.messageType {
                    messageTypeBadge(messageType)
                        .padding(.horizontal)
                }

                // Deadline warning (if applicable)
                if let deadline = message.deadlineDate {
                    deadlineWarning(deadline)
                        .padding(.horizontal)
                }

                // Message body
                VStack(alignment: .leading, spacing: 16) {
                    Text(message.body)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()

                // Primary action button (if available)
                if let primaryAction = message.primaryAction {
                    actionButton(primaryAction, isPrimary: true)
                        .padding(.horizontal)
                }

                // Secondary action link (if available)
                if let secondaryAction = message.secondaryAction {
                    actionButton(secondaryAction, isPrimary: false)
                        .padding(.horizontal)
                }

                // Service name footer (if available)
                if let serviceName = message.serviceName {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        Text("Service: \(serviceName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
    }

    @ViewBuilder
    private func messageTypeBadge(_ type: String) -> some View {
        HStack {
            Image(systemName: iconForMessageType(type))
            Text(type)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(colorForMessageType(type).opacity(0.15))
        .foregroundColor(colorForMessageType(type))
        .cornerRadius(8)
    }

    @ViewBuilder
    private func deadlineWarning(_ deadline: Date) -> some View {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0

        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(daysUntil <= 3 ? .red : .orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("Deadline")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                if daysUntil == 0 {
                    Text("Due today")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } else if daysUntil == 1 {
                    Text("Due tomorrow")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } else if daysUntil < 0 {
                    Text("Overdue")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                } else {
                    Text("Due in \(daysUntil) days")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(deadline, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(daysUntil <= 3 ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
        )
    }

    @ViewBuilder
    private func actionButton(_ action: MessageAction, isPrimary: Bool) -> some View {
        if let urlString = action.link, let url = URL(string: urlString) {
            Link(destination: url) {
                HStack {
                    Text(action.text)
                        .fontWeight(isPrimary ? .semibold : .regular)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isPrimary ? Color.blue : Color.clear)
                .foregroundColor(isPrimary ? .white : .blue)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isPrimary ? Color.clear : Color.blue, lineWidth: 1)
                )
            }
        } else {
            // Action without link (just text)
            HStack {
                Text(action.text)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
        }
    }

    private func iconForMessageType(_ type: String) -> String {
        switch type.lowercased() {
        case "action":
            return "exclamationmark.circle.fill"
        case "update":
            return "info.circle.fill"
        case "confirmation":
            return "checkmark.circle.fill"
        case "legal notice":
            return "doc.text.fill"
        default:
            return "envelope.fill"
        }
    }

    private func colorForMessageType(_ type: String) -> Color {
        switch type.lowercased() {
        case "action":
            return .red
        case "update":
            return .blue
        case "confirmation":
            return .green
        case "legal notice":
            return .purple
        default:
            return .gray
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MessageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MessageDetailView(
                viewModel: MessageDetailViewModel(
                    serviceClient: MockMailboxServiceClient(),
                    token: "preview_token",
                    messageId: "1"
                )
            )
        }
    }
}
#endif
