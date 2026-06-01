import Foundation
import GovKit

@testable import govuk_ios

class MockDVLAAccountSummaryViewModel: DVLAAccountSummaryViewModel {
    override func viewDidAppear() async {
        // do not change view state
    }

    convenience init(viewState: ViewState) {
        self.init(
            viewState: viewState,
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService()
        )
    }
}
