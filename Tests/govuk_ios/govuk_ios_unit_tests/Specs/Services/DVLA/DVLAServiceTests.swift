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
        #expect(drivingLicence.driver.licenceNo == "DECER607085K99AE")
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

    @Test
    func fetchDriverSummary_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedFetchDriverSummaryResult = .success(.arrange)
        let result = await sut.fetchDriverSummary()
        let driverSummary = try #require(try? result.get())
        #expect(driverSummary.response.driver.penaltyPoints == 1)
        #expect(driverSummary.response.driver.firstNames == "KENNETH")
    }

    @Test
    func fetchDriverSummary_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedFetchDriverSummaryResult = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchDriverSummary()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchCustomerSummary_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedFetchCustomerSummaryResult = .success(.arrange)
        let result = await sut.fetchCustomerSummary()
        let customerSummary = try #require(try? result.get())
        let customer = customerSummary.customerResponse.customer
        #expect(customer.customerType == "Individual")
        #expect(customer.individualDetails.firstNames == "KENNETH")
    }

    @Test
    func fetchCustomerSummary_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedFetchCustomerSummaryResult = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchCustomerSummary()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }
}

