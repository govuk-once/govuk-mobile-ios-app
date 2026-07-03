import Foundation
import GovKit

@testable import govuk_ios

class MockDVLAAccountWidgetViewModel: DVLAAccountWidgetViewModel {
    override func viewDidAppear() async {
        // do not change view state
    }

    convenience init(viewState: ViewState) {
        self.init(
            viewState: viewState,
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            dvlaService: MockDVLAService(),
            configService: MockAppConfigService(),
            actions: .empty
        )
    }
}
