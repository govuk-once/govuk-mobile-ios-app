import Foundation
import Testing
import GovKit
@testable import govuk_ios

@Suite(.serialized)
struct APIServiceClientTests_DVLA {
    @Test
    func send_linkAccount_successResponse_returnsExpectedResult() async {
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: DVLAResponseHandler()

        )
        let request = GOVRequest.linkAccount(linkId: "test-link-id")
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 200)
        let expectedData = Data()
        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/v1/udp/identity/dvla/test-link-id") { request in
            return (expectedResponse, expectedData, nil)
        }

        let resultData = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { result in
                    let resultData = try? result.get()
                    continuation.resume(returning: resultData)
                }
            )
        }
        #expect(resultData == expectedData)
    }

    @Test(arguments: zip(
        [403,
         500],
        [DVLAError.authenticationError,
         .apiUnavailable]
    ))
    func send_httpResponseError_returnsExpectedResult(
        statusCode: Int,
        dvlaError: DVLAError
    ) async throws{
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: DVLAResponseHandler()
        )
        let request = GOVRequest.linkAccount(linkId: "test-link-id")
        let expectedResponse = HTTPURLResponse.arrange(statusCode: statusCode)
        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/v1/udp/identity/dvla/test-link-id") { request in
            return (expectedResponse, nil, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? DVLAError)
        #expect(error == dvlaError)
    }
}

