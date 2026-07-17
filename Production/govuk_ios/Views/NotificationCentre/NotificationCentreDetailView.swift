import SwiftUI
import GovKitUI
import GovKit
import MarkdownUI

struct NotificationCentreDetailContainerView: View {
    @ObservedObject var viewModel: NotificationCentreDetailViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        switch viewModel.state {
                        case .loading, .new:
                            NotificationCentreDetailLoadingView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "Loading")
                                }
                        case .loaded(
                            notification: let notification,
                            showDeleteConfirmationSheet: let showConfirmation):
                            NotificationCentreDetailLoadedView(
                                notification: notification,
                                onLinkTapped: {
                                    viewModel.show(url: $0)
                                },
                                onConfirmDelete: {
                                    viewModel.onConfirmDelete()
                                },
                                onCancelDelete: {
                                    viewModel.onCancelDelete()
                                },
                                showDeleteConfirmation: showConfirmation)
                            .onAppear {
                                UIAccessibility.post(notification: .screenChanged,
                                                     argument: "Loading complete")
                            }
                        case .error:
                            NotificationCentreErrorView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "Error")
                                }
                        case .noInternet:
                            NotificationCentreNoInternetView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "No internet connection")
                                }
                        }
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
            }
            if #available(iOS 26.0, *), case .loaded = viewModel.state {
                FloatingIconButtons(
                    unreadAction: viewModel.onMarkUnread, deleteAction: viewModel.onDelete
                )
            }
        }
        .background(Color(UIColor.govUK.fills.surfaceCardEmergencyInfo))
        .onAppear {
            viewModel.onViewAppear()
            viewModel.track(screen: self)
        }
    }
}

@available(iOS 26.0, *)
private struct FloatingIconButtons: View {
    let unreadAction: () -> Void
    let deleteAction: () -> Void
    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                Button {
                   deleteAction()
                } label: {
                    Image(.notcenDelete)
                        .foregroundStyle(Color(.govUK.fills.notificationCentreFloatingIcons))
                        .frame(width: 48, height: 48)
                }
                .glassEffect(.regular.interactive(), in: Circle())
                .accessibilityLabel(.NotificationCentre.notificationCentreDetailDeleteA11YLabel)

                Button {
                    unreadAction()
                } label: {
                    Image(.notcenUnread)
                        .foregroundStyle(Color(.govUK.fills.notificationCentreFloatingIcons))
                        .frame(width: 48, height: 48)
                }
                .glassEffect(.regular.interactive(), in: Circle())
                .accessibilityLabel(.NotificationCentre.notificationCentreDetailUnreadA11YLabel)

                Spacer()
            }
        }
        .padding(.bottom, 32)
        .padding(.horizontal, 28)
    }
}

public struct NotificationCentreDetailLoadedView: View {
    let notification: NotificationCentreDetailViewModel.NotificationDetailContent
    let onLinkTapped: (URL) -> Void
    let onConfirmDelete: () -> Void
    let onCancelDelete: () -> Void
    let showDeleteConfirmation: Bool

    @State private var showSheet: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(notification.date)
                        .font(Font.govUK.callout)
                        .foregroundStyle(Color(UIColor.govUK.text.secondary))
                        .padding(.top, 16)
                        .padding(.bottom, 4)

                    Text(notification.sender)
                        .font(Font.govUK.bodySemibold)
                        .foregroundStyle(Color(UIColor.govUK.text.primary))
                        .padding(.bottom, 16)
                }

                .padding(.horizontal, 16)
                Spacer()
            }
            .background(Color(UIColor.govUK.fills.surfaceCardMsgHeader))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                .NotificationCentre.notificationCentreDetailHeaderAccessibilityLabel(
                    notification.date,
                    notification.sender))

            VStack(alignment: .leading) {
                Text(notification.title)
                    .font(Font.govUK.title1Bold)
                    .padding(.bottom, 16)
                    .foregroundStyle(Color(UIColor.govUK.text.primary))


                Markdown(
                    notification.body)
                .markdownTheme(.govUKNotification)
                .environment(
                    \.openURL,
                     OpenURLAction { url in
                         onLinkTapped(url)
                         return .handled
                     }
                )
            }
            .padding(.top, 24)
            .padding(.horizontal, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .alert(.NotificationCentre.deleteNotificationTitle,
                            isPresented: $showSheet) {
            Button(.NotificationCentre.deleteNotificationConfirmButton,
                   role: .destructive,
                   action: {
                onConfirmDelete()
            })
            Button(.NotificationCentre.deleteNotificationCancelButton, role: .cancel, action: {
                onCancelDelete()
            })
        } message: {
            Text(.NotificationCentre.deleteNotificationBody)
                .font(Font.govUK.body)
                .foregroundStyle(Color(GOVUKColors.text.secondary))
        }
        .onChange(of: showDeleteConfirmation) { showSheet = $0 }
    }
}

public struct NotificationCentreDetailLoadingView: View {
    public var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
            Spacer()
        }
    }
}

extension NotificationCentreDetailContainerView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "Messages Detail" }
}

#Preview("Loading") {
    NotificationCentreDetailLoadingView()
}

#Preview("Loaded") {
    let testNotification = NotificationCentreViewModel.MockData.recentNotifications.first!

    NotificationCentreDetailLoadedView(
        notification: NotificationCentreDetailViewModel
            .NotificationDetailContent(notification: testNotification),
        onLinkTapped: { _ in /* no-op */ },
        onConfirmDelete: { /* no-op */ },
        onCancelDelete: { /* no-op */ },
        showDeleteConfirmation: false)
}

#Preview("Buttons") {
    if #available(iOS 26.0, *) {
        ZStack {
            Color(UIColor.govUK.fills.surfaceCardEmergencyInfo)
            FloatingIconButtons(unreadAction: { /* no-op */ }, deleteAction: { /* no-op */ })
        }
    }
}
