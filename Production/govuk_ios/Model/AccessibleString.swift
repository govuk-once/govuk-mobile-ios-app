import Foundation

struct AccessibleString {
    let displayValue: String
    let accessibilityLabel: String
    init(_ value: String, accessibilityLabel: String? = nil) {
        self.displayValue = value
        self.accessibilityLabel = accessibilityLabel ?? value
    }
}
