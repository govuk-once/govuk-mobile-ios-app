import Foundation
import Testing
@testable import govuk_ios

@Suite
struct DVLAServiceClientTests {

    var mockAPI: MockAPIServiceClient!
    var mockAuthenticationService: MockAuthenticationService!
    var sut: DVLAServiceClient!

    init() {
        mockAPI = MockAPIServiceClient()
        mockAuthenticationService = MockAuthenticationService()
        sut = DVLAServiceClient(
            apiServiceClient: mockAPI,
            authenticationService: mockAuthenticationService
        )
    }

    @Test
    func linkAccount_sendsExpectedRequest() {
        sut.linkAccount(linkId: "test-link-id") { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/v1/udp/identity/dvla/test-link-id")
        #expect(mockAPI._receivedSendRequest?.method == .post)
    }

    @Test
    func linkAccount_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(Data())
        let isSuccess = await withCheckedContinuation { continuation in
            sut.linkAccount(linkId: "test-link-id") { result in
                switch result {
                case .success:
                    continuation.resume(returning: true)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
        #expect(isSuccess == true)
    }

    @Test
    func linkAccount_authenticationError_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(DVLAError.authenticationError)

        let result = await withCheckedContinuation { continuation in
            sut.linkAccount(linkId: "test-link-id") {
                continuation.resume(returning: $0)
            }
        }

        let error = result.getError()
        #expect(error == .authenticationError)
    }

    @Test
    func linkAccount_networkUnavailable_returnsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )

        let result = await withCheckedContinuation { continuation in
            sut.linkAccount(linkId: "test-link-id") { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }
}
