import Foundation
import Testing

@testable import govuk_ios

@Suite
struct DVLAServiceTests {

    var mockServiceClient: MockDVLAServiceClient!
    var sut: DVLAService!

    init() {
        mockServiceClient = MockDVLAServiceClient()
        sut = DVLAService(
            serviceClient: mockServiceClient
        )
    }

    @Test
    func fetchDrivingLicence_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let result = await sut.fetchDrivingLicence()
        let drivingLicence = try #require(try? result.get())
        #expect(drivingLicence.driver.drivingLicenceNumber == "DECER607085K99AE")
        #expect(drivingLicence.token.validFromDate == Date(timeIntervalSince1970: 0))
        #expect(drivingLicence.licence.type == "Full")
    }

    @Test
    func fetchDrivingLicence_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedFetchDrivingLicenceResult = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchDrivingLicence()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

}

