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
        let vehicle = try #require(customerSummary.vehicles.first)
        #expect(vehicle.registrationNumber == "AB71 CDE")
        #expect(vehicle.make == "MITSUBISHI")
        #expect(vehicle.model == "MIRAGE")
        #expect(vehicle.colour == "YELLOW")
    }

    @Test
    func fetchCustomerSummary_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedFetchCustomerSummaryResult = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchCustomerSummary()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchVehicle_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedFetchVehicleResult = .success(.arrange)
        let result = await sut.fetchVehicle(registration: "AA19AMP")
        let vehicle = try #require(try? result.get())
        #expect(vehicle.make == "FORD")
        #expect(vehicle.fuelType == "DIESEL")
    }

    @Test
    func fetchVehicle_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedFetchVehicleResult = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchVehicle(registration: "AA19AMP")
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchShareCodes_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedFetchShareCodesResult = .success(.arrange)
        let result = await sut.fetchShareCodes()
        let response = try #require(try? result.get())
        let shareCode = try #require(response.shareCodes.first)
        #expect(shareCode.token == "ABC-123")
        #expect(shareCode.state == "valid")
    }

    @Test
    func fetchShareCodes_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedFetchShareCodesResult = .failure(.apiUnavailable)
        let result = await sut.fetchShareCodes()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func createShareCode_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedCreateShareCodeResult = .success(.arrange)
        let result = await sut.createShareCode()
        let response = try #require(try? result.get())
        let shareCode = response.shareCode
        #expect(shareCode.tokenId == "token-123")
        #expect(shareCode.driverId == "test-driver-id")
    }

    @Test
    func createShareCode_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedCreateShareCodeResult = .failure(.apiUnavailable)
        let result = await sut.createShareCode()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func cancelShareCode_success_returnsExpectedResult() async throws {
        mockServiceClient._stubbedCancelShareCodeResult = .success(
            .arrange(shareCode: .arrange(state: "cancelled"))
        )
        let result = await sut.cancelShareCode(id: "token-123")
        let response = try #require(try? result.get())
        let shareCode = response.shareCode
        #expect(shareCode.state == "cancelled")
    }

    @Test
    func cancelShareCode_apiUnavailable_returnsExpectedError() async {
        mockServiceClient._stubbedCancelShareCodeResult = .failure(.apiUnavailable)
        let result = await sut.cancelShareCode(id: "token-123")
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }
}

