import Foundation
import Testing

@testable import govuk_ios

@Suite
struct DVLAServiceClientTests {

    let mockAPI: MockAPIServiceClient!
    let sut: DVLAServiceClient!

    init() {
        mockAPI = MockAPIServiceClient()
        sut = DVLAServiceClient(apiServiceClient: mockAPI)
    }

    @Test
    func fetchDrivingLicence_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.fetchDrivingLicence()
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/driving-licence")
        #expect(mockAPI._receivedSendRequest?.method == .get)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func fetchDrivingLicence_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.drivingLicenceResponse)
        let expectedValidFromDate = Date(timeIntervalSince1970: 1746144000)
        let expectedValidToDate = Date(timeIntervalSince1970: 2061590400)

        let result = await sut.fetchDrivingLicence()
        let drivingLicence = try #require(try? result.get())
        #expect(drivingLicence.driver.licenceNo == "DECER607085K99AE")
        #expect(drivingLicence.licence.type == "Full")
        #expect(drivingLicence.licence.status == "Valid")
        #expect(drivingLicence.token.validFromDate == expectedValidFromDate)
        #expect(drivingLicence.token.validToDate == expectedValidToDate)
    }

    @Test
    func fetchDrivingLicence_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchDrivingLicence()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchDrivingLicence_networkUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await sut.fetchDrivingLicence()
        let error = result.getError()
        #expect(error == .networkUnavailable)
    }

    @Test
    func fetchDriverSummary_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.fetchDriverSummary()
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/driver-summary")
        #expect(mockAPI._receivedSendRequest?.method == .get)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func fetchDriverSummary_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.driverSummaryResponse)
        let expectedValidToDate = Date(timeIntervalSince1970: 2061590400)

        let result = await sut.fetchDriverSummary()
        let driverSummary = try #require(try? result.get())
        #expect(driverSummary.response.driver.licenceNo == "DECER607085K99AE")
        #expect(driverSummary.response.driver.firstNames == "KENNETH")
        #expect(driverSummary.response.driver.lastName == "DECERQUEIRA")
        #expect(driverSummary.response.driver.penaltyPoints == 0)
        #expect(driverSummary.response.token.validToDate == expectedValidToDate)
    }

    @Test
    func fetchDriverSummary_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchDriverSummary()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchCustomerSummary_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.fetchCustomerSummary()
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/customer-summary")
        #expect(mockAPI._receivedSendRequest?.method == .get)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func fetchCustomerSummary_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.customerSummaryResponse)

        let result = await sut.fetchCustomerSummary()
        let customerSummary = try #require(try? result.get())
        let customer = customerSummary.customerResponse.customer
        #expect(customer.individualDetails.firstNames == "KENNETH")
        #expect(customer.individualDetails.lastName == "DECERQUEIRA")
        #expect(customer.customerType == "Individual")

        let vehicle = try #require(customerSummary.vehicleResponse.first)
        #expect(vehicle.registrationNumber == "RBZ5119")
        #expect(vehicle.make == "MITSUBISHI")
        #expect(vehicle.model == "MIRAGE")
        #expect(vehicle.taxStatus == "Taxed")
        #expect(vehicle.motStatus == "Not valid")
    }

    @Test
    func fetchCustomerSummary_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchCustomerSummary()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    static var drivingLicenceResponse: Data = {
        .load(filename: "MockDrivingLicenceResponse")
    }()

    static var driverSummaryResponse: Data = {
        .load(filename: "MockDriverSummaryResponse")
    }()

    static var customerSummaryResponse: Data = {
        .load(filename: "MockCustomerSummaryResponse")
    }()
}
