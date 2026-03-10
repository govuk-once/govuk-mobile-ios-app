import Foundation

@testable import govuk_ios
import Testing


@MainActor
@Suite
struct CentreAlignedBarButtonItemTests {
    
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
