import Testing
@testable import govuk_ios

@Suite("StatusInformation Tests")
struct StatusInformationTests {
    // MARK: - Tests for accessibilityLabelOrTitle

    @Test
    func accessibilityLabel_onlyTitle_returnsTitle() {
        // Given a status with only a title
        let statusWithoutLabel = StatusInformation("Loading...")
        #expect(statusWithoutLabel.accessibilityLabel == "Loading...")
    }

    @Test
    func accessibilityLabel_hasAccessibilityLabel_returnsExpectedValue() {
        // Given a status with both a title and an accessibility label
        let statusWithLabel = StatusInformation("Loading...", accessibilityLabel: "Content is currently loading")
        #expect(statusWithLabel.accessibilityLabel == "Content is currently loading")
    }

    @Test
    func displayValue_onlyTitle_returnsExpectedValue() {
        // Given a status with both a title and an accessibility label
        let statusWithLabel = StatusInformation("Loading...")
        #expect(statusWithLabel.displayValue == "Loading...")
    }

    @Test
    func displayValue_titleAndAccessibilityLabel_returnsExpectedValue() {
        // Given a status with both a title and an accessibility label
        let statusWithLabel = StatusInformation("Loading...", accessibilityLabel: "Content is currently loading")
        #expect(statusWithLabel.displayValue == "Loading...")
    }

    // MARK: - Tests for Equatable (==)

    @Test
    func equatable_identicalValues_returnsTrue() {
        let statusA = StatusInformation("Online", accessibilityLabel: "User is online")
        let statusB = StatusInformation("Online", accessibilityLabel: "User is online")

        #expect(statusA == statusB)
    }

    @Test
    func equatable_differentTitles_returnsFalse() {
        let statusA = StatusInformation("Online")
        let statusB = StatusInformation("Offline")

        #expect(statusA != statusB)
    }

    @Test
    func equatable_differentAccessibilityLabels_returnsFalse() {
        let statusA = StatusInformation("Active", accessibilityLabel: "Label A")
        let statusB = StatusInformation("Active", accessibilityLabel: "Label B")

        #expect(statusA != statusB)
    }

    @Test
    func equatable_linkActionsArePresent_returnsTrue() {
        let action1: () -> Void = {}
        let action2: () -> Void = {}

        let noAction = StatusInformation("Clickable", linkAction: nil)
        let hasAction1 = StatusInformation("Clickable", linkAction: action1)
        let hasAction2 = StatusInformation("Clickable", linkAction: action2)

        // One has an action, the other does not -> Not Equal
        #expect(noAction != hasAction1)

        // Both have actions (even if different closures) -> Equal,
        // because your custom '==' only checks if linkAction is nil or not.
        #expect(hasAction1 == hasAction2)
    }
}
