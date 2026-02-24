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
                        case .loading, .new:
                            NotificationCentreLoadingView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged, argument: "Loading")
                                }
                        case .empty:
                            NotificationCentreEmptyView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged, argument: "No Notifications")
                                }
                        case .loaded(notifications: let notifications):
                            NotificationCentreLoadedView(notifications: notifications, onNotificationTap: viewModel.onTapNotification(notification:))
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged, argument: "Loading complete")
                                }
                        case .error:
                            NotificationCentreErrorView(onRetry: viewModel.onTapRetry)
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged, argument: "Error")
                                }
                        }
                    }
                    .frame(minHeight: geometry.size.height)
                    .background(Color(uiColor: UIColor.govUK.fills.surfaceBackground))
                }
                .background(gradient)
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
                Text(self.trackingName)
                    .font(.govUK.largeTitleBold)
                    .multilineTextAlignment(.leading)
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color(UIColor.govUK.text.header))
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, 8)
            .background(Color(UIColor.govUK.fills.surfaceHomeHeaderBackground))
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

fileprivate struct NotificationCentreLoadedView: View {
    let notifications: [Notification]
    let onNotificationTap: (Notification) -> Void
    
    var body: some View {
        List(notifications) { not in
            NotificationCentreRow(notification: not,
                                  onTap:onNotificationTap)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparatorTint(Color(GOVUKColors.text.secondary), edges: .all)
            .alignmentGuide(.listRowSeparatorLeading) { d in
                24 // Align it with the left edge of the content
            }
            .alignmentGuide(.listRowSeparatorTrailing) { d in
                d[.listRowSeparatorTrailing] - 16 // Align with edge of chevron
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
    let onTap: (Notification) -> Void
    
    var body: some View {
        Button {
            onTap(notification)
        } label: {
            
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
        }
    }
}


extension NotificationCentreContainerView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "Notification Centre" }
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
    NotificationCentreRow(notification: notification, onTap: { _ in /* no-op */ })
}

#Preview("Read notification") {
    let notification = Notification(id: "1", title: "Test 1", body: "Body 1", date: Date(), isUnread: false)
    NotificationCentreRow(notification: notification, onTap: { _ in /* no-op */ })
}



