import SwiftUI
import GovKitUI

struct MailboxMessageRow: View {
    let message: MailboxMessage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                senderBadge
                messageContent
                Spacer()
                trailingIndicators
            }
            .padding()
            .background(Color(uiColor: .govUK.fills.surfaceCardDefault))
            .roundedBorder(borderColor: .clear)
            .shadow(
                color: Color(uiColor: .govUK.strokes.cardDefault),
                radius: 0,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(message.isUnopened ? "Unopened message" : "")
    }

    private var senderBadge: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: message.senderColor))
                .frame(width: 40, height: 40)
            Text(message.senderLetter)
                .font(.system(size: message.senderLetter.count > 3 ? 9 : 11, weight: .bold))
                .foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }

    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.senderDisplayName)
                .font(message.isUnopened
                    ? Font.govUK.bodySemibold
                    : Font.govUK.body)
                .foregroundStyle(
                    Color(uiColor: .govUK.text.primary)
                )
            Text(message.subject)
                .font(message.isUnopened
                    ? Font.govUK.bodySemibold
                    : Font.govUK.body)
                .foregroundStyle(
                    Color(uiColor: .govUK.text.primary)
                )
                .lineLimit(2)
            HStack(spacing: 4) {
                if let date = message.receivedDate {
                    Text(Self.relativeDateFormatter.localizedString(
                        for: date, relativeTo: .now
                    ))
                        .font(Font.govUK.caption1)
                        .foregroundStyle(
                            Color(uiColor: .govUK.text.secondary)
                        )
                }
            }
            if let status = message.parsedStatus {
                statusBadge(for: status)
                    .padding(.top, 2)
            }
        }
    }

    private func statusBadge(for status: ActionStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: 10))
                .foregroundStyle(Color(uiColor: status.color))
            Text(status.rawValue)
                .font(Font.govUK.caption1)
                .foregroundStyle(Color(uiColor: status.color))
        }
    }

    private var trailingIndicators: some View {
        HStack(spacing: 8) {
            if message.isUnopened {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .accessibilityHidden(true)
            }
            Image(systemName: "chevron.right")
                .font(Font.govUK.bodySemibold)
                .foregroundStyle(Color(uiColor: .govUK.text.iconTertiary))
                .accessibilityHidden(true)
        }
    }

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}
