import UIKit

protocol VoiceOverFocusServiceInterface {
    func focusHeader(labelled label: String) async
}

struct VoiceOverFocusService: VoiceOverFocusServiceInterface {
    private let maxSearchDepth = 40
    private let delay: TimeInterval
    private let rootElements: () -> [NSObject]
    private let currentFocus: () -> Any?
    private let postNotification: (UIAccessibility.Notification, Any?) -> Void

    init(delay: TimeInterval = 2,
         rootElements: @escaping () -> [NSObject] = VoiceOverFocusService.keyWindows,
         currentFocus: @escaping () -> Any? = {
            UIAccessibility.focusedElement(using: .notificationVoiceOver)
         },
         postNotification: @escaping (UIAccessibility.Notification, Any?) -> Void = {
            UIAccessibility.post(notification: $0, argument: $1)
         }) {
        self.delay = delay
        self.rootElements = rootElements
        self.currentFocus = currentFocus
        self.postNotification = postNotification
    }

    @MainActor
    func focusHeader(labelled label: String) async {
        try? await Task.sleep(for: .seconds(delay))
        guard !Task.isCancelled,
              (currentFocus() as? NSObject)?.accessibilityLabel != label,
              let header = header(labelled: label),
              header.accessibilityFrame.maxY > 0
        else { return }
        postNotification(.layoutChanged, header)
    }

    @MainActor
    private func header(labelled label: String) -> NSObject? {
        for root in rootElements() {
            if let header = search(root, forHeaderLabelled: label, depth: 0) {
                return header
            }
        }
        return nil
    }

    @MainActor
    private func search(_ object: NSObject,
                        forHeaderLabelled label: String,
                        depth: Int) -> NSObject? {
        guard depth < maxSearchDepth else { return nil }
        if object.isAccessibilityElement,
           object.accessibilityTraits.contains(.header),
           object.accessibilityLabel == label {
            return object
        }
        let children = (object.accessibilityElements as? [NSObject])
            ?? (object as? UIView)?.subviews
            ?? []
        for child in children {
            if let header = search(child, forHeaderLabelled: label, depth: depth + 1) {
                return header
            }
        }
        return nil
    }

    static func keyWindows() -> [NSObject] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter(\.isKeyWindow)
    }
}
