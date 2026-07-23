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
        .accessibilityHint(message.status == .unopened ? "Unopened message" : "")
    }

    private var senderBadge: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: message.sender.iconColor))
                .frame(width: 40, height: 40)
            Text(message.sender.iconLetter)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }

    private var isUnopened: Bool {
        message.status == .unopened
    }

    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.sender.rawValue)
                .font(isUnopened
                    ? Font.govUK.bodySemibold
                    : Font.govUK.body)
                .foregroundStyle(
                    Color(uiColor: .govUK.text.primary)
                )
            Text(message.subject)
                .font(isUnopened
                    ? Font.govUK.bodySemibold
                    : Font.govUK.body)
                .foregroundStyle(
                    Color(uiColor: .govUK.text.primary)
                )
                .lineLimit(2)
            Text(message.previewText)
                .font(Font.govUK.caption1)
                .foregroundStyle(
                    Color(uiColor: .govUK.text.secondary)
                )
                .lineLimit(2)
            Text(Self.relativeDateFormatter.localizedString(
                for: message.receivedDate, relativeTo: .now
            ))
                .font(Font.govUK.caption1)
                .foregroundStyle(
                    Color(uiColor: .govUK.text.secondary)
                )
        }
    }

    private var trailingIndicators: some View {
        HStack(spacing: 8) {
            if message.status == .unopened {
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
