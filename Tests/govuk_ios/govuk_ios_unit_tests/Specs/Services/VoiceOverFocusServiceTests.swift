import Foundation
import UIKit
import Testing

@testable import govuk_ios

@MainActor
@Suite
struct VoiceOverFocusServiceTests {
    @Test
    func focusHeader_headerOnScreen_movesVoiceOverToHeader() async {
        let header = UIAccessibilityElement.chatHeader
        let root = container([UIAccessibilityElement.arrange(label: "Hi", traits: .none), header])
        var posted: [(UIAccessibility.Notification, NSObject?)] = []
        let sut = VoiceOverFocusService(
            delay: 0,
            rootElements: { [root] },
            currentFocus: { UIAccessibilityElement.chatTabButton },
            postNotification: { posted.append(($0, $1 as? NSObject)) }
        )

        await sut.focusHeader(labelled: "GOV.UK Chat")

        #expect(posted.count == 1)
        #expect(posted.first?.0 == .layoutChanged)
        #expect(posted.first?.1 === header)
    }

    @Test
    func focusHeader_voiceOverAlreadyOnHeader_doesNotMoveFocus() async {
        let header = UIAccessibilityElement.chatHeader
        var postCount = 0
        let sut = VoiceOverFocusService(
            delay: 0,
            rootElements: { [container([header])] },
            currentFocus: { header },
            postNotification: { _, _ in postCount += 1 }
        )

        await sut.focusHeader(labelled: "GOV.UK Chat")

        #expect(postCount == 0)
    }

    @Test
    func focusHeader_headerScrolledOffScreen_doesNotMoveFocus() async {
        let header = UIAccessibilityElement.arrange(
            frame: CGRect(x: 0, y: -400, width: 140, height: 26)
        )
        var postCount = 0
        let sut = VoiceOverFocusService(
            delay: 0,
            rootElements: { [container([header])] },
            currentFocus: { UIAccessibilityElement.chatTabButton },
            postNotification: { _, _ in postCount += 1 }
        )

        await sut.focusHeader(labelled: "GOV.UK Chat")

        #expect(postCount == 0)
    }

    @Test
    func focusHeader_matchingTextWithoutHeaderTrait_doesNotMoveFocus() async {
        let notAHeader = UIAccessibilityElement.arrange(traits: .staticText)
        var postCount = 0
        let sut = VoiceOverFocusService(
            delay: 0,
            rootElements: { [container([notAHeader])] },
            currentFocus: { UIAccessibilityElement.chatTabButton },
            postNotification: { _, _ in postCount += 1 }
        )

        await sut.focusHeader(labelled: "GOV.UK Chat")

        #expect(postCount == 0)
    }

    @Test
    func focusHeader_leftScreenBeforeDelay_doesNotMoveFocus() async {
        var postCount = 0
        let sut = VoiceOverFocusService(
            delay: 0,
            rootElements: { [container([UIAccessibilityElement.chatHeader])] },
            currentFocus: { UIAccessibilityElement.chatTabButton },
            postNotification: { _, _ in postCount += 1 }
        )

        let task = Task { await sut.focusHeader(labelled: "GOV.UK Chat") }
        task.cancel()
        await task.value

        #expect(postCount == 0)
    }

    @Test
    func focusHeader_headerInsideSubviews_movesVoiceOverToHeader() async {
        let label = UILabel()
        label.isAccessibilityElement = true
        label.accessibilityLabel = "GOV.UK Chat"
        label.accessibilityTraits = .header
        label.accessibilityFrame = CGRect(x: 0, y: 80, width: 140, height: 26)
        let window = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
        window.addSubview(label)
        var postedElement: NSObject?
        let sut = VoiceOverFocusService(
            delay: 0,
            rootElements: { [window] },
            currentFocus: { nil },
            postNotification: { postedElement = $1 as? NSObject }
        )

        await sut.focusHeader(labelled: "GOV.UK Chat")

        #expect(postedElement === label)
    }

    @Test
    func focusHeader_headerNestedBeyondSearchDepth_doesNotMoveFocus() async {
        var shallowPostCount = 0
        var deepPostCount = 0
        let shallow = VoiceOverFocusService(
            delay: 0,
            rootElements: { [self.nested(depth: 5, containing: .chatHeader)] },
            currentFocus: { nil },
            postNotification: { _, _ in shallowPostCount += 1 }
        )
        let deep = VoiceOverFocusService(
            delay: 0,
            rootElements: { [self.nested(depth: 45, containing: .chatHeader)] },
            currentFocus: { nil },
            postNotification: { _, _ in deepPostCount += 1 }
        )

        await shallow.focusHeader(labelled: "GOV.UK Chat")
        await deep.focusHeader(labelled: "GOV.UK Chat")

        #expect(shallowPostCount == 1)
        #expect(deepPostCount == 0)
    }

    @Test
    func focusHeader_defaultDependencies_noHeaderOnScreen_completes() async {
        let sut = VoiceOverFocusService(delay: 0)

        await sut.focusHeader(labelled: "No such header")

        #expect(VoiceOverFocusService.keyWindows().allSatisfy { $0 is UIWindow })
    }

    private func container(_ elements: [NSObject]) -> NSObject {
        let container = NSObject()
        container.accessibilityElements = elements
        return container
    }

    private func nested(depth: Int, containing element: UIAccessibilityElement) -> NSObject {
        let root = NSObject()
        var current = root
        for _ in 1..<depth {
            let child = NSObject()
            current.accessibilityElements = [child]
            current = child
        }
        current.accessibilityElements = [element]
        return root
    }
}
