import UIKit

extension UIAccessibilityElement {
    static var chatHeader: UIAccessibilityElement {
        arrange()
    }

    static var chatTabButton: UIAccessibilityElement {
        arrange(label: "Chat", traits: .button)
    }

    static func arrange(label: String = "GOV.UK Chat",
                        traits: UIAccessibilityTraits = .header,
                        frame: CGRect = CGRect(x: 0, y: 80, width: 140, height: 26)
    ) -> UIAccessibilityElement {
        let element = UIAccessibilityElement(accessibilityContainer: NSObject())
        element.accessibilityLabel = label
        element.accessibilityTraits = traits
        element.accessibilityFrame = frame
        return element
    }
}
