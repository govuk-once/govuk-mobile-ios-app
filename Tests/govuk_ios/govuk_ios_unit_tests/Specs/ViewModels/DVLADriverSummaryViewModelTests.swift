import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DVLADriverSummaryViewModelTests {

    var mockDvlaService: MockDVLAService!
    var sut: DVLADriverSummaryViewModel!

    init() {
        mockDvlaService = MockDVLAService()
        sut = DVLADriverSummaryViewModel(
            dvlaService: mockDvlaService
        )
    }

    @Test
    func fetchDriverSummary_success_createsSectionsCorrectly() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .success(.arrange)
        await sut.fetchDriverSummary()
        try #require(sut.sections.count == 1)
        try #require(sut.sections[0].rows.count == 6)
        #expect(sut.sections[0].rows[2].title == "First names")
        #expect(sut.sections[0].rows[2].body == "KENNETH")
    }

    @Test
    func fetchDrivingLicence_apiUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .failure(.apiUnavailable)
        await sut.fetchDriverSummary()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.dvla.localized("dvlaAccountErrorBody"))
    }

    @Test
    func fetchDrivingLicence_networkUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDriverSummaryResult = .failure(.networkUnavailable)
        await sut.fetchDriverSummary()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("networkUnavailableErrorTitle"))
        #expect(errorViewModel.body == String.common.localized("networkUnavailableErrorBody"))


        await withCheckedContinuation { continuation in
            mockDvlaService._fetchDriverSummaryCalledContinuation = continuation
            errorViewModel.action?()
        }
        #expect(mockDvlaService._fetchDriverSummaryCallCount == 2)
    }

}
