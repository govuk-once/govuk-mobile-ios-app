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
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        #expect(mockDvlaService._fetchDrivingLicenceCallCount == 1)
    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_createsDrivingLicenceSummaryViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(licenceNumber: "ABC123DE")
        )
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var licenceSummaryViewModel: DrivingLicenceSummaryViewModel?
        if case .loaded(let licenceSummary, _) = sut.viewState {
            licenceSummaryViewModel = licenceSummary
        }
        let unwrappedLicenceSummaryViewModel = try #require(licenceSummaryViewModel)
        #expect(unwrappedLicenceSummaryViewModel.licenceNumber == "ABC123DE")
    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_createsDrivingRecordViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var drivingRecordViewModel: DrivingRecordViewModel?
        if case .loaded(_, let drivingRecord) = sut.viewState {
            drivingRecordViewModel = drivingRecord
        }
        let unwrappedDrivingRecordViewModel = try #require(drivingRecordViewModel)
        let drivingRecordRow = try #require(unwrappedDrivingRecordViewModel.listContent.first?.rows.first)
        #expect(drivingRecordRow.title == String(localized: .DVLA.drivingRecordButtonTitle))
    }

    @Test
    func viewDidAppear_fetchLicenceFailure_createsErrorViewModel() async throws {
        let mockDriverDetailsURLString = "https://dvla.gov.uk/driver-details"
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.apiUnavailable)
        mockConfigService._dvlaUrls = .arrange(driverDetails: mockDriverDetailsURLString)
        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var errorViewModel: InlineActionErrorViewModel?
        if case .error(let error) = sut.viewState {
            errorViewModel = error
        }
        #expect(errorViewModel?.title == String(localized: .DVLA.licenceSummaryErrorTitle))
        let expectedButtonTitle = String(localized: .DVLA.licenceSummaryErrorButtonTitle)
        let expectedMarkdownBody = String(localized: .DVLA.licenceSummaryErrorBody(
            buttonTitle: expectedButtonTitle,
            url: mockDriverDetailsURLString)
        )
        #expect(errorViewModel?.markdownBody == expectedMarkdownBody)
        errorViewModel?.openURLAction(URL(string: mockDriverDetailsURLString)!)
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["text"] as? String == expectedButtonTitle)
        #expect(trackedEvent.params?["url"] as? String == mockDriverDetailsURLString)
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["type"] as? String == "Button")
    }

    @Test
    func licenceStatusViewModelAction_tracksOpenURLEvent() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(licenceStatus: .expired)
        )
        mockConfigService._dvlaUrls = .arrange(renewLicence: "https://renewLicence.com")

        let sut = DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var licenceSummaryViewModel: DrivingLicenceSummaryViewModel?
        if case .loaded(let licenceSummary, _) = sut.viewState {
            licenceSummaryViewModel = licenceSummary
        }
        let unwrappedLicenceSummaryViewModel = try #require(licenceSummaryViewModel)
        unwrappedLicenceSummaryViewModel.licenceStatusViewModel.buttonAction?()
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["text"] as? String == String(localized: .DVLA.renewLicenceButtonTitle))
        #expect(trackedEvent.params?["url"] as? String == "https://renewLicence.com")
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["type"] as? String == "Button")
    }
}

