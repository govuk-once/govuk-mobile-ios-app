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
        let postcode = UUID().uuidString
        let data = try! jsonEncoder().encode(Constants.addresses)
        let url = LocalWasteServiceClient.url(path: "api/address/\(postcode)")!
        MockURLProtocol.registerHandler(forUrl: url.absoluteString) { request in
            #expect(request.httpMethod == "GET")
            return (.arrangeSuccess, data, nil)
        }

        let sut = LocalWasteServiceClient(session: URLSession.mock)

        // when
        let actual = try await sut.fetchAddresses(postcode: postcode)

        // then
        #expect(actual == Constants.addresses)
    }

    @Test
    func fetchAddresses_statusCode500_throwsError() async throws {

        // given
        let postcode = UUID().uuidString
        let url = LocalWasteServiceClient.url(path: "api/address/\(postcode)")!
        MockURLProtocol.registerHandler(forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 500), nil, nil)
        }

        let sut = LocalWasteServiceClient(session: URLSession.mock)

        // when / then
        await #expect(throws: LocalWasteAddressSearchError.apiUnavailable) {
            let _ = try await sut.fetchAddresses(postcode: postcode)
        }
    }

    @Test
    func fetchAddresses_notConnectedToInternet_throwsError() async throws {

        // given
        let postcode = UUID().uuidString
        let url = LocalWasteServiceClient.url(path: "api/address/\(postcode)")!
        MockURLProtocol.registerHandler(forUrl: url.absoluteString) { request in
            return (.arrange(statusCode: 500), nil, NSError(domain: "test", code: NSURLErrorNotConnectedToInternet))
        }

        let sut = LocalWasteServiceClient(session: URLSession.mock)

        // when / then
        await #expect(throws: LocalWasteAddressSearchError.networkUnavailable) {
            let _ = try await sut.fetchAddresses(postcode: postcode)
        }
    }

    @Test
    func fetchAddresses_decodingError_throwsError() async throws {

        // given
        let postcode = UUID().uuidString
        let data = try! jsonEncoder().encode(TestStruct(property: "test"))
        let url = LocalWasteServiceClient.url(path: "api/address/\(postcode)")!
        MockURLProtocol.registerHandler(forUrl: url.absoluteString) { request in
            return (.arrangeSuccess, data, nil)
        }

        let sut = LocalWasteServiceClient(session: URLSession.mock)

        // when / then
        await #expect(throws: LocalWasteAddressSearchError.decodingError) {
            let _ = try await sut.fetchAddresses(postcode: postcode)
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
        static let postcode = "SE129PT"
        
        static let addresses = [
            LocalWasteAddress(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1"),
            LocalWasteAddress(addressFull: "address2", uprn: "uprn2", localCustodianCode: "code2"),
        ]
    }
}
