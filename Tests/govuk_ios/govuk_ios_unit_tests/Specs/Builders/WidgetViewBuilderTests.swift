import SwiftUI
import Testing

@testable import govuk_ios

@Suite
struct WidgetViewBuilderTests {

    @Test
    func dvlaAccount_returnsExpectedResult() {
        let sut = WidgetViewBuilder()
        let result = sut.dvlaAccountWidget(
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            dvlaService: MockDVLAService(),
            linkAction: {},
            unlinkAction: {},
            viewLicenceAction: {},
            viewDriverSummaryAction: {},
            viewCustomerSummaryAction: {}
        )
        #expect(result is DVLAAccountWidgetView)
    }
}

