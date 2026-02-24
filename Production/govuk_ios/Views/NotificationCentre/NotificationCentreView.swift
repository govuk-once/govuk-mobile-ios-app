//

import SwiftUI
import GovKitUI

struct NotificationCentreContainerView: View {
    @ObservedObject var viewModel: NotificationCentreViewModel
    
    var body: some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .loading, .new:
                NotificationCentreLoadingView()
            case .empty:
                NotificationCentreEmptyView()
            case .loaded(notifications: let notifications):
                NotificationCentreLoadedView(notifications: notifications, onNotificationTap: viewModel.onTapNotification(notification:))
            case .error:
                NotificationCentreErrorView(onRetry: viewModel.onTapRetry)
            }
        }
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

fileprivate struct NotificationCentreLoadedView: View {
    let notifications: [Notification]
    let onNotificationTap: (Notification) -> Void
    
    var body: some View {
        List {
            ForEach(Array(notifications.enumerated()), id: \.offset) { index, not in
                NotificationCentreRow(notification: not,
                                      isLastRow: index < notifications.count - 1,
                                      onTap:onNotificationTap)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparatorTint(Color(GOVUKColors.text.secondary), edges: .all)
                    .alignmentGuide(.listRowSeparatorLeading) { d in
                        24 // Align it with the left edge of the content (
                    }
                    .alignmentGuide(.listRowSeparatorTrailing) { d in
                        d[.listRowSeparatorTrailing] - 16
                    }
            }

        }
    }
}

fileprivate struct NotificationCentreLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
            Spacer()
        }
    }
}


fileprivate struct NotificationCentreErrorView: View {
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
            
            SwiftUIButton(.primary, viewModel: .init(localisedTitle: String(localized: .NotificationCentre.notificationErrorButtonRetry), action: onRetry))
            .padding(.top, 32)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

fileprivate struct NotificationCentreEmptyView: View {
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

fileprivate struct NotificationCentreRow: View {
    let notification: Notification
    let isLastRow: Bool
    let onTap: (Notification) -> Void
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(notification.isUnread ? Color(GOVUKColors.fills.surfaceListSelected) : .clear)
                .frame(width: 8)
                .padding(.vertical, 1)
                .accessibilityHidden(!notification.isUnread)
                .accessibilityLabel(Text(.NotificationCentre.notificationUnreadA11YLabel))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(notification.title)
                    .lineLimit(2)
                    .font(Font.govUK.headlineSemibold)
                    .padding(.bottom, 4)
                    .foregroundStyle(Color(UIColor.govUK.text.primary))
                Text(notification.body)
                    .lineLimit(3)
                    .font(Font.govUK.subheadline)
                    .padding(.bottom, 8)
                    .foregroundStyle(Color(UIColor.govUK.text.secondary))
                Text(.NotificationCentre.notificationSentDateFormat(DateFormatter.notificationSent.string(from: notification.date)))
                    .font(Font.govUK.footnote)
                    .foregroundStyle(Color(UIColor.govUK.text.secondary))

            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            
            Spacer()
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .padding(.trailing, 16)
                .accessibilityHidden(true)
                .foregroundStyle(Color(GOVUKColors.fills.surfaceListSelected))
        }
        .accessibilityElement(children: .combine)
        .onTapGesture {
            onTap(notification)
        }
    }
}

#Preview("Loading") {
    NotificationCentreLoadingView()
}

#Preview("Loaded") {
    let oneDay: Double = 60 * 60 * 24
    let now = Date()
    let testNotifications = NotificationCentreViewModel.MockData.testNotifications
    
    NotificationCentreLoadedView(notifications: testNotifications, onNotificationTap: { _ in /* No-op */ })
}

#Preview("Empty") {
    NotificationCentreEmptyView()
}

#Preview("Error") {
    NotificationCentreErrorView(onRetry: { /* no-op */ })
}

#Preview("Unread notification") {
    let notification = Notification(id: "1", title: "Test 1", body: "Body 1", date: Date(), isUnread: true)
    NotificationCentreRow(notification: notification, isLastRow: true, onTap: { _ in /* no-op */ })
}

#Preview("Read notification") {
    let notification = Notification(id: "1", title: "Test 1", body: "Body 1", date: Date(), isUnread: false)
    NotificationCentreRow(notification: notification, isLastRow: true, onTap: { _ in /* no-op */ })
}



