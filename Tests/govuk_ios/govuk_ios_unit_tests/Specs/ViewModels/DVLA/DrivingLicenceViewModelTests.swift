import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct DrivingLicenceViewModelTests {

    var mockAnalyticsService: MockAnalyticsService!
    var mockDvlaService: MockDVLAService!
    var mockConfigService: MockAppConfigService!

    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockDvlaService = MockDVLAService()
        mockConfigService = MockAppConfigService()
    }

    @Test
    func viewDidAppear_fetchesLicence() async {
        mockDvlaService._stubbedFetchDriverSummaryResult = .success(.arrange)
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        #expect(mockDvlaService._fetchDriverSummaryCallCount == 1)
    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_createsDrivingLicenceSummaryViewModel() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .success(
            .arrange(licenceNo: "ABC123DE")
        )
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var licenceSummaryViewModel: DrivingLicenceSummaryViewModel?
        if case .loaded(let licenceSummary) = sut.viewState {
            licenceSummaryViewModel = licenceSummary
        }
        let unwrappedLicenceSummaryViewModel = try #require(licenceSummaryViewModel)
        #expect(unwrappedLicenceSummaryViewModel.licenceNumber == "ABC123DE")
    }

    @Test
    func viewDidAppear_fetchLicenceFailure_createsErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .failure(.apiUnavailable)
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var errorViewModel: AppErrorViewModel?
        if case .error(let error) = sut.viewState {
            errorViewModel = error
        }
        #expect(errorViewModel?.title == String.common.localized("genericErrorTitle"))
    }
}

