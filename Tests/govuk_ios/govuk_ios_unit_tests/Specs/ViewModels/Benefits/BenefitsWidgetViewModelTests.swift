import Foundation
import Combine
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct BenefitsWidgetViewModelTests {
    private let mockAnalyticsService = MockAnalyticsService()
    private lazy var sut = BenefitsWidgetViewModel(
        analyticsService: mockAnalyticsService,
        linkAction: {}
    )

    @Test
     func init_setsInitialStateToLoading() {
         let sut = BenefitsWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            linkAction: {}
         )
         
         #expect({
             if case .loading = sut.state { return true }
             return false
         }())
     }
    
    @Test
    func fetchDWPData_updatesStateToUnlinkedWithExpectedCardDetails() async {
        let sut = BenefitsWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            linkAction: {}
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
