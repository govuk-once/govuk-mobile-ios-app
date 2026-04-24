import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DVLAAccountViewModelTests {

    var mockDvlaService: MockDVLAService!

    init() {
        mockDvlaService = MockDVLAService()
    }

    @Test
    func fetchContent_drivingLicence_success_createsSectionsCorrectly() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .drivingLicence
        )
        await sut.fetchContent()
        try #require(sut.sections.count == 1)
        try #require(sut.sections[0].rows.count == 5)
        #expect(sut.sections[0].rows[0].title == "Licence number")
        #expect(sut.sections[0].rows[0].body == "DECER607085K99AE")
    }

    @Test
    func fetchContent_drivingLicence_apiUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.apiUnavailable)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .drivingLicence
        )
        await sut.fetchContent()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.dvla.localized("dvlaAccountErrorBody"))
    }

    @Test
    func fetchContent_drivingLicence_networkUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.networkUnavailable)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .drivingLicence
        )
        await sut.fetchContent()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("networkUnavailableErrorTitle"))
        #expect(errorViewModel.body == String.common.localized("networkUnavailableErrorBody"))


        await withCheckedContinuation { continuation in
            mockDvlaService._fetchDrivingLicenceCalledContinuation = continuation
            errorViewModel.action?()
        }
        #expect(mockDvlaService._fetchDrivingLicenceCallCount == 2)
    }

    @Test
    func fetchContent_driverSummary_success_createsSectionsCorrectly() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .driverSummary
        )
        await sut.fetchContent()
        try #require(sut.sections.count == 1)
        try #require(sut.sections[0].rows.count == 6)
        #expect(sut.sections[0].rows[2].title == "First names")
        #expect(sut.sections[0].rows[2].body == "KENNETH")
    }

    @Test
    func fetchContent_driverSummary_apiUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .failure(.apiUnavailable)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .driverSummary
        )
        await sut.fetchContent()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.dvla.localized("dvlaAccountErrorBody"))
    }

    @Test
    func fetchContent_customerSummary_success_createsSectionsCorrectly() async throws {
        mockDvlaService._stubbedFetchCustomerSummaryResult = .success(
            .arrange(vehicles: [.arrange])
        )
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .customerSummary
        )
        await sut.fetchContent()
        try #require(sut.sections.count == 2)
        try #require(sut.sections[0].rows.count == 3)
        try #require(sut.sections[1].rows.count == 1)
        #expect(sut.sections[0].rows[2].title == "Customer type")
        #expect(sut.sections[0].rows[2].body == "Individual")
        let expectedVehicleRowTitle = """
            Registration number: AB71 CDE
            Make: MITSUBISHI
            Model: MIRAGE
            Tax status:  Taxed
            MOT status: Not valid
            """
        #expect(sut.sections[1].rows[0].title == expectedVehicleRowTitle)
    }
}
