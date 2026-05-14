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

        let vehicle = try #require(customerSummary.vehicles.first)
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

    @Test
    func fetchVehicle_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.fetchVehicle(registration: "AA19AMP")
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/vehicle-enquiry/AA19AMP")
        #expect(mockAPI._receivedSendRequest?.method == .get)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func fetchVehicle_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.vehicleResponse)

        let result = await sut.fetchVehicle(registration: "AA19AMP")
        let vehicle = try #require(try? result.get())
        #expect(vehicle.make == "FORD")
        #expect(vehicle.fuelType == "DIESEL")
        #expect(vehicle.colour == "BLACK")
        let expectedTaxDueDate = Date(timeIntervalSince1970: 1809648000)
        #expect(vehicle.taxDueDate == expectedTaxDueDate)
    }

    @Test
    func fetchVehicle_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchVehicle(registration: "AA19AMP")
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchShareCodes_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.fetchShareCodes()
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/share-codes")
        #expect(mockAPI._receivedSendRequest?.method == .get)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func fetchShareCodes_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.listShareCodesResponse)
        let result = await sut.fetchShareCodes()
        let response = try #require(try? result.get())
        #expect(response.shareCodes.count == 2)
        let shareCode = try #require(response.shareCodes.first)
        #expect(shareCode.state == "cancelled")
        #expect(shareCode.token == "kNvqM4Hr")
        #expect(shareCode.tokenId == "cf3f210c-c542-4ed0-84c9-75caa1d76cc5")
        let expectedCreatedDate = Date(timeIntervalSince1970: 1778497623)
        #expect(shareCode.created == expectedCreatedDate)
    }

    @Test
    func fetchShareCodes_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.fetchShareCodes()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func createShareCode_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.createShareCode()
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/share-code")
        #expect(mockAPI._receivedSendRequest?.method == .post)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func createShareCode_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.createShareCodeResponse)
        let result = await sut.createShareCode()
        let response = try #require(try? result.get())
        let shareCode = response.shareCode
        #expect(shareCode.state == "valid")
        #expect(shareCode.token == "vVNxXP4R")
        #expect(shareCode.tokenId == "2b923159-faff-4171-bc59-bd0ca84e3249")
        let expectedCreatedDate = Date(timeIntervalSince1970: 1778574495)
        #expect(shareCode.created == expectedCreatedDate)
        let expectedExpiryDate = Date(timeIntervalSince1970: 1780388895)
        #expect(shareCode.expiry == expectedExpiryDate)
    }

    @Test
    func createShareCode_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.createShareCode()
        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func cancelShareCode_sendsExpectedRequest() async {
        mockAPI._stubbedSendResponse = .success(Data())
        _ = await sut.cancelShareCode(id: "test-share-code-id")
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/dvla/v1/share-code/test-share-code-id/cancel")
        #expect(mockAPI._receivedSendRequest?.method == .post)
        #expect(mockAPI._receivedSendRequest?.additionalHeaders == ["Content-Type": "application/json"])
    }

    @Test
    func cancelShareCode_success_returnsExpectedResult() async throws {
        mockAPI._stubbedSendResponse = .success(Self.cancelShareCodeResponse)
        let result = await sut.cancelShareCode(id: "2b923159-test")
        let response = try #require(try? result.get())
        let shareCode = response.shareCode
        #expect(shareCode.state == "cancelled")
        #expect(shareCode.token == "vVNxXP4R")
        let expectedCancelledDate = Date(timeIntervalSince1970: 1778574583)
        #expect(shareCode.cancelled == expectedCancelledDate)
    }

    @Test
    func cancelShareCode_apiUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.apiUnavailable)
        let result = await sut.cancelShareCode(id: "test-share-code-id")
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

    static var vehicleResponse: Data = {
        .load(filename: "MockVehicleResponse")
    }()

    static var listShareCodesResponse: Data = {
        .load(filename: "MockListShareCodesResponse")
    }()

    static var createShareCodeResponse: Data = {
        .load(filename: "MockCreateShareCodeResponse")
    }()

    static var cancelShareCodeResponse: Data = {
        .load(filename: "MockCancelShareCodeResponse")
    }()
}
