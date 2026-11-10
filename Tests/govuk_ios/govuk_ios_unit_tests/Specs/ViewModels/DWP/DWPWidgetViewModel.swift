import Foundation
import Combine
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DWPWidgetViewModelTests {
    private let mockAnalyticsService = MockAnalyticsService()
    private lazy var sut = DWPWidgetViewModel(
        analyticsService: mockAnalyticsService
    )

    @Test
     func init_setsInitialStateToLoading() {
         let sut = DWPWidgetViewModel(
             analyticsService: MockAnalyticsService()
         )
         
         #expect({
             if case .loading = sut.state { return true }
             return false
         }())
     }

    @Test
    func fetchDWPData_updatesStateToUnlinkedWithExpectedCardDetails() async {
        let sut = DWPWidgetViewModel(
            analyticsService: MockAnalyticsService()
        )
        var stateUpdates = sut.$state
            .dropFirst()
            .values
            .makeAsyncIterator()
        sut.fetchDWPData()

        let updatedState = await stateUpdates.next()
        guard case .unlinked(let linkCard) = updatedState else {
            return
        }

        #expect(linkCard.title == String.dwp.localized("dwpAccountLinkCardTitle"))
        #expect(linkCard.subtitle == String.dwp.localized("dwpAccountLinkCardSubtitle"))
    }
}
