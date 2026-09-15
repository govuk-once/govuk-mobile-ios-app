import Testing
@testable import govuk_ios

@Suite("StatusInformation Tests")
struct StatusInformationTests {
    // MARK: - Tests for accessibilityLabelOrTitle

    @Test("Returns accessibility label when present, otherwise falls back to title")
    func testAccessibilityLabelOrTitle() {
        // Given a status with only a title
        let statusWithoutLabel = StatusInformation("Loading...")
        #expect(statusWithoutLabel.accessibilityLabelOrTitle == "Loading...")

        // Given a status with both a title and an accessibility label
        let statusWithLabel = StatusInformation("Loading...", accessibilityLabel: "Content is currently loading")
        #expect(statusWithLabel.accessibilityLabelOrTitle == "Content is currently loading")
    }

    // MARK: - Tests for Equatable (==)

    @Test("Identical properties are equal")
    func testEqualityWithIdenticalValues() {
        let statusA = StatusInformation("Online", accessibilityLabel: "User is online")
        let statusB = StatusInformation("Online", accessibilityLabel: "User is online")

        #expect(statusA == statusB)
    }

    @Test("Different titles result in inequality")
    func testInequalityByTitle() {
        let statusA = StatusInformation("Online")
        let statusB = StatusInformation("Offline")

        #expect(statusA != statusB)
    }

    @Test("Different accessibility labels result in inequality")
    func testInequalityByAccessibilityLabel() {
        let statusA = StatusInformation("Active", accessibilityLabel: "Label A")
        let statusB = StatusInformation("Active", accessibilityLabel: "Label B")

        #expect(statusA != statusB)
    }

    @Test("Link action presence determines equality, not closure contents")
    func testEqualityByLinkActionPresence() {
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
