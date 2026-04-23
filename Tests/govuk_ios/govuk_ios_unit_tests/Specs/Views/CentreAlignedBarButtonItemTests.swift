import Foundation
import Testing

@testable import govuk_ios

@MainActor
@Suite
struct CenterAlignedBarButtonItemTests {

    @Test
    func centreAlignedBarButtonItem_returnsExpectedConfiguration() {
        let sut = CenterAlignedBarButtonItem(
            title: "test",
            tint: .clear,
            action: {_ in}
        )
        #expect(sut.actionButton.isEnabled == true)
    }
}
