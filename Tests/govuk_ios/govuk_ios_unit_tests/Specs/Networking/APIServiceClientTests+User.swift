import Foundation
import Testing
import GovKit
@testable import govuk_ios

@Suite(.serialized)
struct APIServiceClientTests_User {
    @Test
    func send_successResponse_returnsExpectedResult() async {
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: UserResponseHandler()

        )
        let request = GOVRequest.userState
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 200)
        let expectedData = Data()
        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/v1/user") { request in
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
        [401,
         403,
         500],
        [UserStateError.authenticationError,
         .authenticationError,
         .apiUnavailable]
    ))
    func send_httpResponseError_returnsExpectedResult(
        statusCode: Int,
        userStateError: UserStateError
    ) async throws{
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: UserResponseHandler()
        )
        let request = GOVRequest.userState
        let expectedResponse = HTTPURLResponse.arrange(statusCode: statusCode)
        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/v1/user") { request in
            return (expectedResponse, nil, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? UserStateError)
        #expect(error == userStateError)
    }
}
