import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LocalWasteServiceClientTests {

    // MockURLProtocol is NOT thread safe and these tests run concurrently
    // so each test uses a UUID as the postcode, so that the tests don't
    // intefere with each other.
    
    @Test
    func fetchAddresses_statusCode200_returnsAddresses() async throws {

        // given
        let sessionId = UUID().uuidString
        let data = try! jsonEncoder().encode(Constants.addresses)
        let url = LocalWasteServiceClient.url(path: "api/address/\(Constants.postcode)")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            #expect(request.httpMethod == "GET")
            return (.arrangeSuccess, data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when
        let actual = try await sut.fetchAddresses(postcode: Constants.postcode)

        // then
        #expect(actual == Constants.addresses)
    }

    @Test
    func fetchAddresses_statusCode400_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let errorResponse = LocalWasteAddressError(
            message: .councilNotSupported
        )
        let data = try! jsonEncoder().encode(errorResponse)
        let url = LocalWasteServiceClient.url(path: "api/address/\(Constants.postcode)")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 400), data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteAddressesApiError.apiError(.councilNotSupported)) {
            let _ = try await sut.fetchAddresses(postcode: Constants.postcode)
        }
    }

    @Test
    func fetchAddresses_statusCode500_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let url = LocalWasteServiceClient.url(path: "api/address/\(Constants.postcode)")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 500), nil, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteAddressesApiError.apiUnavailable) {
            let _ = try await sut.fetchAddresses(postcode: Constants.postcode)
        }
    }

    @Test
    func fetchAddresses_notConnectedToInternet_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let url = LocalWasteServiceClient.url(path: "api/address/\(Constants.postcode)")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 500), nil, NSError(domain: "test", code: NSURLErrorNotConnectedToInternet))
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteAddressesApiError.networkUnavailable) {
            let _ = try await sut.fetchAddresses(postcode: Constants.postcode)
        }
    }

    @Test
    func fetchAddresses_statusCode200_decodingError_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let data = try! jsonEncoder().encode(TestStruct(property: "test"))
        let url = LocalWasteServiceClient.url(path: "api/address/\(Constants.postcode)")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrangeSuccess, data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteAddressesApiError.decodingError) {
            let _ = try await sut.fetchAddresses(postcode: Constants.postcode)
        }
    }

    @Test
    func fetchAddresses_statusCode400_decodingError_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let data = try! jsonEncoder().encode(TestStruct(property: "test"))
        let url = LocalWasteServiceClient.url(path: "api/address/\(Constants.postcode)")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 400), data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteAddressesApiError.decodingError) {
            let _ = try await sut.fetchAddresses(postcode: Constants.postcode)
        }
    }

    @Test
    func fetchSchedule_statusCode200_returnsSchedule() async throws {

        // given
        let sessionId = UUID().uuidString
        let data = try! jsonEncoder().encode(Constants.bins)
        let url = LocalWasteServiceClient.url(path: "api/schedule")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            #expect(request.httpMethod == "GET")

            let queryItems = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)?.queryItems
            #expect(queryItems?.count == 2)
            #expect(queryItems?[0].name == "uprn")
            #expect(queryItems?[0].value == Constants.uprn)
            #expect(queryItems?[1].name == "localCustodianCode")
            #expect(queryItems?[1].value == Constants.custodianCode)

            return (.arrangeSuccess, data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when
        let actual = try await sut.fetchSchedule(uprn: Constants.uprn, localCustodianCode: Constants.custodianCode)

        // then
        #expect(actual == Constants.bins)
    }

    @Test
    func fetchSchedule_statusCode400_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let errorResponse = LocalWasteScheduleError(
            message: .councilNotSupported
        )
        let data = try! jsonEncoder().encode(errorResponse)
        let url = LocalWasteServiceClient.url(path: "api/schedule")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 400), data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteScheduleApiError.apiError(.councilNotSupported)) {
            let _ = try await sut.fetchSchedule(uprn: Constants.uprn, localCustodianCode: Constants.custodianCode)
        }
    }

    @Test
    func fetchSchedule_statusCode500_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let url = LocalWasteServiceClient.url(path: "api/schedule")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 500), nil, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteScheduleApiError.apiUnavailable) {
            let _ = try await sut.fetchSchedule(uprn: Constants.uprn, localCustodianCode: Constants.custodianCode)
        }
    }

    @Test
    func fetchSchedule_notConnectedToInternet_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let url = LocalWasteServiceClient.url(path: "api/schedule")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 500), nil, NSError(domain: "test", code: NSURLErrorNotConnectedToInternet))
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteScheduleApiError.networkUnavailable) {
            let _ = try await sut.fetchSchedule(uprn: Constants.uprn, localCustodianCode: Constants.custodianCode)
        }
    }

    @Test
    func fetchSchedule_statusCode200_decodingError_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let data = try! jsonEncoder().encode(TestStruct(property: "test"))
        let url = LocalWasteServiceClient.url(path: "api/schedule")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrangeSuccess, data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteScheduleApiError.decodingError) {
            let _ = try await sut.fetchSchedule(uprn: Constants.uprn, localCustodianCode: Constants.custodianCode)
        }
    }

    @Test
    func fetchSchedule_statusCode400_decodingError_throwsError() async throws {

        // given
        let sessionId = UUID().uuidString
        let data = try! jsonEncoder().encode(TestStruct(property: "test"))
        let url = LocalWasteServiceClient.url(path: "api/schedule")!
        MockURLProtocol.registerHandler(sessionId: sessionId, forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 400), data, nil)
        }

        let session = URLSession.mock(sessionId: sessionId)
        let sut = LocalWasteServiceClient(session: session)

        // when / then
        await #expect(throws: LocalWasteScheduleApiError.decodingError) {
            let _ = try await sut.fetchSchedule(uprn: Constants.uprn, localCustodianCode: Constants.custodianCode)
        }
    }

    private func jsonEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(LocalWasteServiceClient.dateFormatter)
        return encoder
    }

    struct TestStruct: Encodable {
        let property: String
    }
    
    struct Constants {
        static let postcode = "the-postcode"
        static let uprn = "the-uprn"
        static let custodianCode = "the-code"
        static let addresses = [
            LocalWasteAddress(addressFull: "address1",
                              uprn: "uprn1",
                              localCustodianCode: "code1"),
            LocalWasteAddress(addressFull: "address2",
                              uprn: "uprn2",
                              localCustodianCode: "code2"),
        ]
        static let bins = [
            LocalWasteBin(date: LocalWasteServiceClient.dateFormatter.date(from: "2026-03-16")!,
                          name: "Black",
                          color: .black,
                          content: "general waste"),
            LocalWasteBin(date: LocalWasteServiceClient.dateFormatter.date(from: "2026-03-15")!,
                          name: "Green",
                          color: .green,
                          content: "recycling")
        ]
    }
}
