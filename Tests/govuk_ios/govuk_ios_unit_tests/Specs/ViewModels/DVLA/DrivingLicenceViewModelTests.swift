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

    private func makeSUT() -> DrivingLicenceViewModel {
        DrivingLicenceViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            categoriesAction: { _ in },
            openURLAction: { _ in }
        )
    }

    @Test
    func viewDidAppear_fetchesLicence() async {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = makeSUT()
        await sut.viewDidAppear()
        #expect(mockDvlaService._fetchDrivingLicenceCallCount == 1)
    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_createsDrivingLicenceSummaryViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(licenceNumber: "ABC123DE")
        )
        let sut = makeSUT()
        await sut.viewDidAppear()
        var licenceSummaryViewModel: DrivingLicenceSummaryViewModel?
        if case .loaded(let loadedState) = sut.viewState {
            licenceSummaryViewModel = loadedState.licenceSummary
        }
        let unwrappedLicenceSummaryViewModel = try #require(licenceSummaryViewModel)
        #expect(unwrappedLicenceSummaryViewModel.licenceNumber == "ABC123DE")
    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_createsDrivingRecordViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = makeSUT()
        await sut.viewDidAppear()
        var drivingRecordViewModel: DrivingRecordViewModel?
        if case .loaded(let loadedState) = sut.viewState {
            drivingRecordViewModel = loadedState.drivingRecord
        }
        let unwrappedDrivingRecordViewModel = try #require(drivingRecordViewModel)
        let drivingRecordRow = try #require(unwrappedDrivingRecordViewModel.listContent.first?.rows.first)
        #expect(drivingRecordRow.title == String(localized: .DVLA.drivingRecordButtonTitle))
    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_createsCategoriesViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = makeSUT()
        await sut.viewDidAppear()
        var categoriesViewModel: LicenceCategoriesSectionViewModel?
        if case .loaded(let loadedState) = sut.viewState {
            categoriesViewModel = loadedState.categories
        }
        let unwrappedCategoriesViewModel = try #require(categoriesViewModel)
        let categoriesRow = try #require(unwrappedCategoriesViewModel.listContent.first?.rows.first)
        #expect(categoriesRow.title == String(localized: .DVLA.licenceCategoriesButtonTitle))
    }

// temporarily reverse licence state mapping behaviour for release
//    @Test(arguments: [
//        DrivingLicenceStatus.surrendered,
//        .surrenderedVoluntarily,
//        .surrenderedForMedicalReasons,
//        .exchanged
//    ])
//    func viewDidAppear_fetchLicenceSuccess_licenceStatusSurrenderedOrExchanged_createsNoticeViewModel(status: DrivingLicenceStatus) async throws {
//        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(
//            .arrange(licenceStatus: status)
//        )
//        let sut = makeSUT()
//        await sut.viewDidAppear()
//        var licenceNoticeViewModel: DrivingLicenceNoticeViewModel?
//        if case .notice(let notice) = sut.viewState {
//            licenceNoticeViewModel = notice
//        }
//        let unwrappedLicenceNoticeViewModel = try #require(licenceNoticeViewModel)
//        #expect(unwrappedLicenceNoticeViewModel.title == String(localized: .DVLA.licenceNotFoundTitle))
//        #expect(unwrappedLicenceNoticeViewModel.body == String(localized: .DVLA.licenceNotFoundBody))
//    }

    @Test
    func viewDidAppear_fetchLicenceSuccess_licenceStatusUnknown_createsNoticeViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(licenceStatus: .unknown)
        )
        let sut = makeSUT()
        await sut.viewDidAppear()
        var licenceNoticeViewModel: DrivingLicenceNoticeViewModel?
        if case .notice(let notice) = sut.viewState {
            licenceNoticeViewModel = notice
        }
        let unwrappedLicenceNoticeViewModel = try #require(licenceNoticeViewModel)
        #expect(unwrappedLicenceNoticeViewModel.title == String(localized: .DVLA.licenceNotAvailableTitle))
        #expect(unwrappedLicenceNoticeViewModel.body == String(localized: .DVLA.licenceNotAvailableBody))
    }

    @Test
    func viewDidAppear_fetchLicenceFailure_createsErrorViewModel() async throws {
        let mockDriverDetailsURLString = "https://dvla.gov.uk/driver-details"
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.serviceUnavailable(statusCode: nil))
        mockConfigService._dvlaUrls = .arrange(driverDetails: mockDriverDetailsURLString)
        let sut = makeSUT()
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
    func viewDidAppear_fetchLicenceFailure_licenceNotAvailable_createsNoticeViewModel() async throws {
        let mockDriverDetailsURLString = "https://dvla.gov.uk/driver-details"
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.notAvailable())
        mockConfigService._dvlaUrls = .arrange(driverDetails: mockDriverDetailsURLString)
        let sut = makeSUT()
        await sut.viewDidAppear()
        var licenceNoticeViewModel: DrivingLicenceNoticeViewModel?
        if case .notice(let notice) = sut.viewState {
            licenceNoticeViewModel = notice
        }
        #expect(licenceNoticeViewModel?.title == String(localized: .DVLA.licenceNotAvailableTitle))
        #expect(licenceNoticeViewModel?.body == String(localized: .DVLA.licenceNotAvailableBody))

        licenceNoticeViewModel?.action?.handler()
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["text"] as? String == String(localized: .DVLA.licenceNotAvailableButtonTitle))
        #expect(trackedEvent.params?["url"] as? String == mockDriverDetailsURLString)
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["type"] as? String == "Button")
    }

    @Test
    func viewDidAppear_fetchLicenceFailure_licenceNotFound_createsNoticeViewModel() async {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.notFound())
        let sut = makeSUT()
        await sut.viewDidAppear()
        var licenceNoticeViewModel: DrivingLicenceNoticeViewModel?
        if case .notice(let notice) = sut.viewState {
            licenceNoticeViewModel = notice
        }
        #expect(licenceNoticeViewModel?.title == String(localized: .DVLA.licenceNotFoundTitle))
        #expect(licenceNoticeViewModel?.body == String(localized: .DVLA.licenceNotFoundBody))
        #expect(licenceNoticeViewModel?.action == nil)
    }

    @Test
    func licenceStatusViewModelAction_tracksOpenURLEvent() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(licenceStatus: .expired)
        )
        mockConfigService._dvlaUrls = .arrange(renewLicence: "https://renewLicence.com")

        let sut = makeSUT()
        await sut.viewDidAppear()
        var licenceSummaryViewModel: DrivingLicenceSummaryViewModel?
        if case .loaded(let loadedState) = sut.viewState {
            licenceSummaryViewModel = loadedState.licenceSummary
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

    @Test
    func licenceCategoriesSectionViewModelAction_tracksNavigationEvent() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = makeSUT()
        await sut.viewDidAppear()
        var categoriesViewModel: LicenceCategoriesSectionViewModel?
        if case .loaded(let loadedState) = sut.viewState {
            categoriesViewModel = loadedState.categories
        }
        let unwrappedCategoriesViewModel = try #require(categoriesViewModel)
        let categoriesRow = try #require(unwrappedCategoriesViewModel.listContent.first?.rows.first as? NavigationRow)
        categoriesRow.action()

        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["text"] as? String == String(localized: .DVLA.licenceCategoriesButtonTitle))
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["type"] as? String == "Button")
    }
}

