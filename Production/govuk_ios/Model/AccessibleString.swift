import Foundation

/// A string wrapper that provides a distinct accessibility label
/// alongside its primary display value.
struct AccessibleString: Equatable {
    let displayValue: String
    let accessibilityLabel: String

    /// Creates an accessible string with a display value and an optional accessibility label.
    /// - Parameters:
    ///   - value: The string shown visually in the UI.
    ///   - accessibilityLabel: The description read by screen readers. Defaults to `value` if nil.
    init(_ value: String, accessibilityLabel: String? = nil) {
        self.displayValue = value
        self.accessibilityLabel = accessibilityLabel ?? value
    }
}
