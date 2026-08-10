import Foundation

@testable import govuk_ios

extension MailboxMessage {
    static var arrange: MailboxMessage {
        arrange()
    }

    static func arrange(
        messageId: String = "message-1",
        mailboxId: String = "mailbox-1",
        receivedAt: String = "2026-08-10T09:48:30.289Z",
        subject: String = "Test subject",
        senderDept: String = "hmrc",
        body: String? = "Test body",
        readAt: String? = nil
    ) -> MailboxMessage {
        .init(
            messageId: messageId,
            mailboxId: mailboxId,
            receivedAt: receivedAt,
            subject: subject,
            senderDept: senderDept,
            body: body,
            readAt: readAt
        )
    }
}
