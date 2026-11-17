import UIKit

extension UIView {
    /// Recursively searches the view's accessibility hierarchy and subviews for an element
    /// matching the given `accessibilityLabel`.
    /// - Parameter label: The accessibility label to match.
    /// - Returns: The matching accessibility element or view, or `nil` if none is found.
    func findAccessibilityElement(matchingLabel label: String?) -> Any? {
        guard let label, !label.isEmpty else { return nil }

        if isAccessibilityElement, accessibilityLabel == label {
            return self
        }

        return matchInAccessibilityElements(label: label)
            ?? matchInIndexedAccessibilityElements(label: label)
            ?? subviews.lazy.compactMap { $0.findAccessibilityElement(matchingLabel: label) }.first
    }

    private func matchInAccessibilityElements(label: String) -> Any? {
        guard let elements = accessibilityElements else { return nil }

        for element in elements {
            if let accObject = element as? NSObject, accObject.accessibilityLabel == label {
                return accObject
            }
            if let subview = element as? UIView,
               let match = subview.findAccessibilityElement(matchingLabel: label) {
                return match
            }
        }
        return nil
    }

    private func matchInIndexedAccessibilityElements(label: String) -> Any? {
        let count = accessibilityElementCount()
        guard count != NSNotFound else { return nil }

        return (0..<count)
            .lazy
            .compactMap { [weak self] in
                self?.accessibilityElement(at: $0) as? NSObject
            }
            .first { $0.accessibilityLabel == label }
    }
}
