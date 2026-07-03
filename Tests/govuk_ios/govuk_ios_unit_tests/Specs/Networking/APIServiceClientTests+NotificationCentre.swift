import Foundation
import Testing
import GovKit
@testable import govuk_ios

@Suite(.serialized)
struct APIServiceClientTests_NotificationCentre {

    // MARK: - All Notifications
    @Test
    func send_notifications_passesExpectedValues() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedAccessToken = "testToken"
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: NotificationCentreResponseHandler(),
            tokenProvider: mockAuthenticationService

        )
        let request = GOVRequest.notifications

        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/uns/v1/notifications") { request in
            #expect(request.httpMethod == "GET")
            #expect(request.allHTTPHeaderFields?["Content-Type"] == nil)
            #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer testToken")
            return (.arrangeSuccess, nil, nil)
        }

        return await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { result in
                    continuation.resume(returning: Void())
                }
            )
        }
    }

    @Test
    func send_successResponse_returnsExpectedResult() async {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedAccessToken = "testToken"
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: NotificationCentreResponseHandler(),
            tokenProvider: mockAuthenticationService

        )
        let request = GOVRequest.notifications
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 200)
        let expectedData = Data()
        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/uns/v1/notifications") { request in
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
        [404,
         500],
        [NotificationCentreError.notFound,
         .apiUnavailable]
    ))
    func send_httpResponseError_returnsExpectedResult(
        statusCode: Int,
        chatError: NotificationCentreError
    ) async throws{
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedAccessToken = "testToken"
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.google.com")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: NotificationCentreResponseHandler(),
            tokenProvider: mockAuthenticationService

        )
        let request = GOVRequest.notifications
        let expectedResponse = HTTPURLResponse.arrange(statusCode: statusCode)
        MockURLProtocol.registerHandler(forUrl: "https://www.google.com/app/uns/v1/notifications") { request in
            return (expectedResponse, nil, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? NotificationCentreError)
        #expect(error == chatError)
    }
}
