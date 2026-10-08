import SwiftUI
import GovKit

struct ChatHeaderView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @AccessibilityFocusState private var isFocused: Bool
    private let focusDelay = 2.0
    private let focusRetryInterval = 2.0
    private let focusResetInterval = 0.1
    private let focusMaxRequests = 3
    private let elementSearchMaxDepth = 40
    var body: some View {
        Text(.Chat.chatHeader)
            .font(.govUK.title2Bold)
            .foregroundStyle(Color(UIColor.govUK.text.primary))
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($isFocused)
            .padding(.bottom, 4.0)
            .task {
                guard voiceOverEnabled else { return }
                await focusOnArrival()
            }
            .onDisappear {
                isFocused = false
            }
    }
    private func focusOnArrival() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                _ = await voiceOverReachesHeader()
            }
            group.addTask { @MainActor in
                await requestFocusUntilMoved()
            }
            await group.next()
            group.cancelAll()
        }
    }
    private func voiceOverReachesHeader() async -> Bool {
        let header = headerText
        return await NotificationCenter.default
            .notifications(named: UIAccessibility.elementFocusedNotification)
            .contains { notification in
                let element = notification.userInfo?[
                    UIAccessibility.focusedElementUserInfoKey
                ] as? NSObject
                return element?.accessibilityLabel == header
            }
    }
    private func requestFocusUntilMoved() async {
        try? await Task.sleep(for: .seconds(focusDelay))
        var startElement: NSObject?
        for request in 1...focusMaxRequests {
            guard !Task.isCancelled, !isVoiceOverOnHeader else { return }
            if request > 1 {
                guard isVoiceOverStill(on: startElement) else { return }
            }
            startElement = voiceOverFocusedElement
            await moveVoiceOverToHeader(isRetry: request > 1)
            try? await Task.sleep(for: .seconds(focusRetryInterval))
        }
    }
    private func moveVoiceOverToHeader(isRetry: Bool) async {
        if let header = headerElement() {
            guard header.accessibilityFrame.maxY > 0 else { return }
            UIAccessibility.post(notification: .layoutChanged, argument: header)
            return
        }
        if isRetry {
            isFocused = false
            try? await Task.sleep(for: .seconds(focusRetryInterval))
        }
        isFocused = true
    }

    private func headerElement() -> NSObject? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter(\.isKeyWindow)
            .lazy
            .compactMap { findHeader(in: $0, depth: 0) }
            .first
    }

    private func findHeader(in object: NSObject, depth: Int) -> NSObject? {
        guard depth < elementSearchMaxDepth else { return nil }
        if object.isAccessibilityElement,
           object.accessibilityTraits.contains(.header),
           object.accessibilityLabel == headerText {
            return object
        }
        let children = (object.accessibilityElements as? [NSObject])
            ?? (object as? UIView)?.subviews
            ?? []
        for child in children {
            if let header = findHeader(in: child, depth: depth + 1) {
                return header
            }
        }
        return nil
    }

    private func isVoiceOverStill(on element: NSObject?) -> Bool {
        let current = voiceOverFocusedElement
        return current === element ||
            (element != nil && current?.accessibilityLabel == element?.accessibilityLabel)
    }

    private var voiceOverFocusedElement: NSObject? {
        UIAccessibility.focusedElement(using: .notificationVoiceOver) as? NSObject
    }

    private var isVoiceOverOnHeader: Bool {
        voiceOverFocusedElement?.accessibilityLabel == headerText
    }

    private var headerText: String {
        String(localized: .Chat.chatHeader)
    }
}
