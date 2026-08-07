import Foundation
import Testing
import GovKit
@testable import govuk_ios

@Suite(.serialized)
struct APIServiceClientTests_DVLA {
    @Test
    func send_errorResponseLicenceNotFound404_returnsLicenceNotFound() async throws {
        let jsonString = """
        {
            "error": {
                "code": "GUK-404-04",
                "message": "No driving licence could be found."
            }
        }
        """
        let mockResponseData = jsonString.data(using: .utf8)

        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.gov.uk")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: DVLAResponseHandler()
        )
        let request = GOVRequest.drivingLicence
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 404)
        MockURLProtocol.registerHandler(forUrl: "https://www.gov.uk/app/dvla/v1/customer/licence") { request in
            return (expectedResponse, mockResponseData, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? DVLAError)
        #expect(error == .notFound)
    }

    @Test
    func send_errorResponseLicenceNotAvailable404_returnsLicenceNotAvailable() async throws {
        let jsonString = """
        {
            "error": {
                "code": "GUK-404-05",
                "message": "Driving licence not available for enquiry"
            }
        }
        """
        let mockResponseData = jsonString.data(using: .utf8)

        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.dvla.gov.uk")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: DVLAResponseHandler()
        )
        let request = GOVRequest.drivingLicence
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 404)
        MockURLProtocol.registerHandler(forUrl: "https://www.dvla.gov.uk/app/dvla/v1/customer/licence") { request in
            return (expectedResponse, mockResponseData, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? DVLAError)
        #expect(error == .notAvailable)
    }

    @Test
    func send_invalidErrorResponse_returnsApiUnavailable() async throws {
        let jsonString = """
        {
            "errorMessage": "Test error with invalid response format"
        }
        """
        let mockResponseData = jsonString.data(using: .utf8)

        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.dvla.gov.uk")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: DVLAResponseHandler()
        )
        let request = GOVRequest.drivingLicence
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 404)
        MockURLProtocol.registerHandler(forUrl: "https://www.dvla.gov.uk/app/dvla/v1/customer/licence") { request in
            return (expectedResponse, mockResponseData, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? DVLAError)
        #expect(error == .apiUnavailable)
    }

    @Test
    func send_errorResponseGeneric404_returnsApiUnavailable() async throws {
        let subject = APIServiceClient(
            baseUrl: URL(string: "https://www.dvla.gov.uk")!,
            session: URLSession.mock,
            requestBuilder: RequestBuilder(),
            responseHandler: DVLAResponseHandler()
        )
        let request = GOVRequest.drivingLicence
        let expectedResponse = HTTPURLResponse.arrange(statusCode: 404)
        MockURLProtocol.registerHandler(forUrl: "https://www.dvla.gov.uk/app/dvla/v1/customer/licence") { request in
            return (expectedResponse, nil, nil)
        }

        let result = await withCheckedContinuation { continuation in
            subject.send(
                request: request,
                completion: { continuation.resume(returning: $0) }
            )
        }
        let error = try #require(result.getError() as? DVLAError)
        #expect(error == .apiUnavailable)
    }
}
