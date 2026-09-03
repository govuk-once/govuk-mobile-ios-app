import Foundation

@testable import govuk_ios

extension govuk_ios.Notification {
    static var arrange: govuk_ios.Notification {
        arrange()
    }

    static func arrange(
        id: String = "1",
        title: String = "Test title",
        body: String = "Test body",
        date: Date = .init(),
        status: String = "UNREAD",
        messageTitle: String? = nil,
        messageBody: String? = nil,
        metadata: govuk_ios.Notification.Metadata = .arrange
    ) -> govuk_ios.Notification {
        .init(
            id: id,
            title: title,
            body: body,
            date: date,
            status: status,
            messageTitle: messageTitle,
            messageBody: messageBody,
            metadata: metadata
        )
    }
}

extension govuk_ios.Notification.Metadata {
    static var arrange: govuk_ios.Notification.Metadata {
        arrange()
    }

    static func arrange(
        sender: govuk_ios.Notification.Metadata.Sender = .arrange
    ) -> govuk_ios.Notification.Metadata {
        .init(sender: sender)
    }
}

extension govuk_ios.Notification.Metadata.Sender {
    static var arrange: govuk_ios.Notification.Metadata.Sender {
        arrange()
    }

    static func arrange(
        displayName: String = "Test"
    ) -> govuk_ios.Notification.Metadata.Sender {
        .init(displayName: displayName)
    }
}
