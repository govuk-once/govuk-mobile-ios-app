//

import SwiftUI
import GovKitUI
import GovKit

struct NotificationCentreDetailContainerView: View {
    @ObservedObject var viewModel: NotificationCentreDetailViewModel

    var body: some View {
        VStack { // Hides the splash of white when you overscroll the list
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        titleView

                        switch viewModel.state {
                        case .loading, .new:
                            NotificationCentreDetailLoadingView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "Loading")
                                }
                        case .notFound:
                            NotificationCentreDetailNotFoundView()
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "No Notifications")
                                }
                        case .loaded(notification: let notification):
                            NotificationCentreDetailLoadedView(
                                notification: notification,
                                onLinkTapped: {
                                    // swiftlint:disable:next todo
                                    // TODO Combine these?
                                    viewModel.show(url: $0)
                                    viewModel.track(url: $0)
                                })
                            .onAppear {
                                UIAccessibility.post(notification: .screenChanged,
                                                     argument: "Loading complete")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 32)
                        case .error:
                            NotificationCentreDetailErrorView(onRetry: viewModel.onTapRetry)
                                .onAppear {
                                    UIAccessibility.post(notification: .screenChanged,
                                                         argument: "Error")
                                }
                        }
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
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
                Text(.NotificationCentre.notificationDetailTitle)
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

private struct NotificationCentreDetailLoadedView: View {
    let notification: Notification
    let onLinkTapped: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(notification.messageTitle ?? notification.title)
                .font(Font.govUK.title1Bold)
                .padding(.bottom, 16)
                .foregroundStyle(Color(UIColor.govUK.text.primary))
            Text(.NotificationCentre.notificationSentDateFormat(
                DateFormatter.notificationSent.string(from: notification.date)))
                .font(Font.govUK.callout)
                .foregroundStyle(Color(UIColor.govUK.text.secondary))
                .padding(.bottom, 32)
            Text((notification.messageBody ?? notification.body)
                .toDetectedAttributedString())
                .font(Font.govUK.body)
                .foregroundStyle(Color(UIColor.govUK.text.primary))
                .environment(\.openURL, OpenURLAction { url in
                        onLinkTapped(url)
                        return .handled
                    })

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(UIColor.govUK.fills.surfaceCardEmergencyInfo))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct NotificationCentreDetailLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
            Spacer()
        }
    }
}


private struct NotificationCentreDetailErrorView: View {
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
            Text(.NotificationCentre.notificationDetailErrorBody)
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

private struct NotificationCentreDetailNotFoundView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 16)
                .foregroundStyle(Color(GOVUKColors.fills.surfaceCardEmergencyLocal))
            Text(.NotificationCentre.notificationNotFoundTitle)
                .padding(.bottom, 16)
                .font(Font.govUK.title1)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
            Text(.NotificationCentre.notificationNotFoundBody)
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.secondary))
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}


extension NotificationCentreDetailContainerView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "Notification Centre Detail" }
}

extension String {
    // Borrowed from https://fatbobman.com/en/posts/open_url_in_swiftui/
    func toDetectedAttributedString() -> AttributedString {
        var attributedString = AttributedString(self)

        let types = NSTextCheckingResult.CheckingType.link.rawValue

        guard let detector = try? NSDataDetector(types: types) else {
            return attributedString
        }

        let matches = detector.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count))

        for match in matches {
            let range = match.range
            let startIndex = attributedString
                .index(attributedString.startIndex, offsetByCharacters: range.lowerBound)
            let endIndex = attributedString.index(startIndex, offsetByCharacters: range.length)
            // Setting URL for link
            if match.resultType == .link, let url = match.url {
                attributedString[startIndex..<endIndex].link = url
            }
        }
        return attributedString
    }
}

#Preview("Loading") {
    NotificationCentreDetailLoadingView()
}

#Preview("Loaded") {
    let testNotification = NotificationCentreViewModel.MockData.testNotifications.first!

    NotificationCentreDetailLoadedView(
        notification: testNotification,
        onLinkTapped: { _ in /* no-op */ })
}

#Preview("Not Found") {
    NotificationCentreDetailNotFoundView()
}

#Preview("Error") {
    NotificationCentreDetailErrorView(onRetry: { /* no-op */ })
}
