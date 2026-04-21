import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DVLADrivingLicenceViewModelTests {

    var mockDvlaService: MockDVLAService!
    var sut: DVLADrivingLicenceViewModel!

    init() {
        mockDvlaService = MockDVLAService()
        sut = DVLADrivingLicenceViewModel(
            dvlaService: mockDvlaService
        )
    }

    @Test
    func fetchDrivingLicence_success_createsSectionsCorrectly() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        await sut.fetchDrivingLicence()
        try #require(sut.sections.count == 1)
        try #require(sut.sections[0].rows.count == 5)
        #expect(sut.sections[0].rows[0].title == "Licence number")
        #expect(sut.sections[0].rows[0].body == "DECER607085K99AE")
    }

    @Test
    func fetchDrivingLicence_apiUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.apiUnavailable)
        await sut.fetchDrivingLicence()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.dvla.localized("dvlaAccountErrorBody"))
    }

    @Test
    func fetchDrivingLicence_networkUnavailable_setsExpectedErrorViewModel() async throws {
        mockDvlaService._stubbedFetchDrivingLicenceResult = .failure(.networkUnavailable)
        await sut.fetchDrivingLicence()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("networkUnavailableErrorTitle"))
        #expect(errorViewModel.body == String.common.localized("networkUnavailableErrorBody"))


        await withCheckedContinuation { continuation in
            mockDvlaService._fetchDrivingLicenceCalledContinuation = continuation
            errorViewModel.action?()
        }
        #expect(mockDvlaService._fetchDrivingLicenceCallCount == 2)
    }

}
