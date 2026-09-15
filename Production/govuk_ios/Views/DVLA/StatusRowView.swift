import SwiftUI
import GovKitUI

/// A view that displays a status title, rendering as an interactive link
/// if an action is available, or as plain text otherwise.
struct StatusRowView: View {
    let status: StatusInformation

    var body: some View {
        if let statusLinkAction = status.linkAction {
            StatusLinkButton(
                text: status.title,
                accessibilityLabel:
                    status.accessibilityLabelOrTitle,
                action: statusLinkAction
            )
        } else {
            Text(status.title)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(status.accessibilityLabelOrTitle)
        }
    }
}

struct StatusLinkButton: View {
    let text: String
    let accessibilityLabel: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            StatusLinkContent(text: text)
        }
        .accessibilityLabel(
            accessibilityLabel ?? text
        )
    }
}

/// A label representing an external link.
struct StatusLinkContent: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .multilineTextAlignment(.leading)
                .font(Font.govUK.body)
            Spacer()

            Image(systemName: "arrow.up.forward")
                .font(Font.govUK.bodySemibold)
        }
        .foregroundStyle(
            Color(UIColor.govUK.text.link)
        )
    }
}

#if DEBUG
#Preview("StatusLinkContent") {
    VStack {
        StatusLinkContent(text: "some label")
    }
}

#Preview("StatusLinkButton") {
    VStack {
        StatusLinkButton(text: "StatusLinkView",
                       accessibilityLabel: "accessible",
                       action: {})
    }
}

#Preview("StatusRowView") {
    let statusWithNoAction = StatusInformation(
        title: "status with no action",
        accessibilityLabel: "accessibilityLabel",
        linkAction: nil)

    let statusWithAction = StatusInformation(
        title: "status with an action",
        accessibilityLabel: "accessibilityLabel",
        linkAction: {})

    VStack {
        StatusRowView(status: statusWithNoAction)
        StatusRowView(status: statusWithAction)
    }
}
#endif // DEBUG
