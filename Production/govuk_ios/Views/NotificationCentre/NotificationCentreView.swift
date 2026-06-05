//

import SwiftUI
import GovKitUI
import GovKit

struct NotificationCentreContainerView: View {
    @ObservedObject var viewModel: NotificationCentreViewModel

    var body: some View {
        VStack { // Hides the splash of white when you overscroll the list
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        titleView

                        switch viewModel.state {
                        case .loading:
                            NotificationCentreLoadingView()
                                .onAppear {
                                    UIAccessibility
                                        .post(notification: .screenChanged, argument: "Loading")
                                }
                        case .empty:
                            NotificationCentreEmptyView()
                                .onAppear {
                                    UIAccessibility
                                        .post(notification: .screenChanged,
                                              argument: "No Notifications")
                                }
                        case .loaded(notifications: let notifications):
                            NotificationCentreLoadedView(
                                notifications: notifications,
                                onNotificationTap: viewModel.onTapNotification(notification:))
                            .onAppear {
                                UIAccessibility
                                    .post(notification: .screenChanged,
                                          argument: "Loading complete")
                            }
                        case .error:
                            NotificationCentreErrorView(onRetry: viewModel.onTapRetry)
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "Error")
                                }
                        }
                    }
                    .frame(minHeight: geometry.size.height)
                    .background(Color(uiColor: UIColor.govUK.fills.surfaceBackground))
                }
//                .background(gradient)
            }
        }
        .background(Color(UIColor.govUK.fills.surfaceBackground))
        .onAppear {
            viewModel.onViewAppear()
            viewModel.track(screen: self)
        }
    }


    private var titleView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Messages") // TO DO Put in strings file
                    .font(.govUK.largeTitleBold)
                    .multilineTextAlignment(.leading)
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, 0)
            .background(Color(.clear))
        }
    }

    // Hides the splash of white when you overscroll the title
    private var gradient: Gradient {
        Gradient(stops: [
            .init(
                color: Color(UIColor.govUK.fills.surfaceHomeHeaderBackground),
                location: 0),
            .init(
                color: Color(UIColor.govUK.fills.surfaceHomeHeaderBackground),
                location: 0.33),
            .init(
                color: .clear,
                location: 0.33),
            .init(
                color: .clear,
                location: 1)
        ])
    }
}

private struct NotificationCentreLoadedView: View {
    let notifications: NotificationCentreViewModel.NotificationGroups
    let onNotificationTap: (Notification) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if !notifications.recent.isEmpty {
                    SectionHeader(title: "Recent")

                    ForEach(notifications.recent) { not in
                        NotificationCentreRow(notification: not,
                                              onTap: onNotificationTap)
                    }
                }

                if !notifications.older.isEmpty {
                    SectionHeader(title: "Last 30 days")

                    ForEach(notifications.older) { not in
                        NotificationCentreRow(notification: not,
                                              onTap: onNotificationTap)
                    }
                }

                Text("Messages are deleted after 30 days.")
                    .font(.govUK.callout)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.govUK.text.secondary))
                    .clipShape(Rectangle())
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .background(Color(UIColor.govUK.fills.surfaceBackground))
        }
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.govUK.title3Semibold)
                .multilineTextAlignment(.leading)
                .accessibility(addTraits: .isHeader)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .padding(.top, 28)
                .padding(.bottom, 16)
            Spacer()
        }
    }
}

private struct NotificationCentreLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
            Spacer()
        }
    }
}


private struct NotificationCentreErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 16)
                .foregroundStyle(Color(GOVUKColors.fills.surfaceCardEmergencyLocal))
            Text(.NotificationCentre.notificationErrorTitle)
                .padding(.bottom, 16)
                .font(Font.govUK.title1)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
            Text(.NotificationCentre.notificationErrorBody)
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(UIColor.govUK.text.secondary))

            SwiftUIButton(.primary,
                          viewModel: .init(
                            localisedTitle: String(
                                localized: .NotificationCentre.notificationErrorButtonRetry),
                            action: onRetry))
            .padding(.top, 32)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

private struct NotificationCentreEmptyView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(.notcenBell)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 16)
                .foregroundStyle(Color(GOVUKColors.fills.surfaceCardEmergencyLocal))
            Text(.NotificationCentre.noNotificationsTitle)
                .padding(.bottom, 16)
                .font(Font.govUK.title1)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
            Text(.NotificationCentre.noNotificationsBody)
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.secondary))
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

private struct NotificationCentreRow: View {
    let notification: Notification
    let onTap: (Notification) -> Void

    var body: some View {
        Button {
            onTap(notification)
        } label: {
            HStack {
                Circle()
                    .fill(notification.isUnread ?
                          Color(UIColor.govUK.fills.msgUnread) :
                            Color(UIColor.govUK.fills.msgRead))
                    .frame(width: 10, height: 10)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .accessibilityHidden(!notification.isUnread)
                    .accessibilityLabel(Text(.NotificationCentre.notificationUnreadA11YLabel))

                VStack(alignment: .leading, spacing: 0) {
                    Text(notification.title)
                        .lineLimit(1)
                        .font(Font.govUK.bodySemibold)
                        .padding(.bottom, 4)
                        .foregroundStyle(Color(UIColor.govUK.text.primary))

                    Text(notification.date.formatMessageListDate())
                        .font(Font.govUK.subheadline)
                        .foregroundStyle(Color(UIColor.govUK.text.secondary))
                }
                .padding(.trailing, 16)

                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .cornerRadius(10)
            .accessibilityElement(children: .combine)
        }
    }
}

extension NotificationCentreContainerView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "Notification Centre" } // TO DO Update this
}

#Preview("Loading") {
    NotificationCentreLoadingView()
}

#Preview("Loaded") {
    let testNotifications = NotificationCentreViewModel.MockData.testNotifications

    NotificationCentreLoadedView(
        notifications: testNotifications,
        onNotificationTap: { _ in /* No-op */ })
}

#Preview("Empty") {
    NotificationCentreEmptyView()
}

#Preview("Error") {
    NotificationCentreErrorView(onRetry: { /* no-op */ })
}

#Preview("Unread notification") {
    let notification = Notification(
        id: "1", title: "Test 1", body: "Body 1", date: Date(), status: "UNREAD",
        messageTitle: nil, messageBody: nil)
    NotificationCentreRow(notification: notification, onTap: { _ in /* no-op */ })
}

#Preview("Read notification") {
    let notification = Notification(
        id: "1", title: "Test 1", body: "Body 1", date: Date(), status: "READ",
        messageTitle: nil, messageBody: nil)
    NotificationCentreRow(notification: notification, onTap: { _ in /* no-op */ })
}
