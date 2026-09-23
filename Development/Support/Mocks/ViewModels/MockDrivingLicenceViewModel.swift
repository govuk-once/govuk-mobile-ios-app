import Foundation

@testable import govuk_ios

class MockDrivingLicenceViewModel: DrivingLicenceViewModel {
    var _viewDidAppearCalled: Bool = false
    override func viewDidAppear() async {
        _viewDidAppearCalled = true
    }

    convenience init(viewState: ViewState) {
        self.init(
            viewState: viewState,
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
    }
}
