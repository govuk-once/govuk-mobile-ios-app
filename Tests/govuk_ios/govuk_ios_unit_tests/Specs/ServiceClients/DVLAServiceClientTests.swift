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
        #expect(drivingLicence.driver.drivingLicenceNumber == "DECER607085K99AE")
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

    static var drivingLicenceResponse: Data = {
        .load(filename: "MockDrivingLicenceResponse")
    }()
}
