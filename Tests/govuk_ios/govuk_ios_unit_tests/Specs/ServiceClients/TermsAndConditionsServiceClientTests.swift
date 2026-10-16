import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
struct TermsAndConditionsServiceClientTests {
    let sut: TermsAndConditionsServiceClient
    let mockServiceClient: MockAPIServiceClient

    init() {
        mockServiceClient = MockAPIServiceClient()
        sut = TermsAndConditionsServiceClient(
            serviceClient: mockServiceClient
        )
    }

    @Test
    func termsAndConditions_sendsRequest() async {
        mockServiceClient._stubbedSendResponse = .success(Data())
        _ = await sut.termsAndConditions(path: "/api/content/guidance/govuk-app-terms-and-conditions")
        #expect(mockServiceClient._receivedSendRequest?.urlPath == "/api/content/guidance/govuk-app-terms-and-conditions")
    }

    @Test
    func termsAndConditions_validJson_returnsCorrectConfig() async throws {
        let mockJsonData = Data.loadFixture("MockTermsAndConditionsResponse")
        mockServiceClient._stubbedSendResponse = .success(mockJsonData)
        let result = await sut.termsAndConditions(path: "/api/content/guidance/govuk-app-terms-and-conditions")
        let unwrappedResult = try result.get()
        #expect(unwrappedResult.publicUpdatedAt.ISO8601Format() == "2026-03-20T11:25:39Z")
    }

    @Test
    func fetchAppConfig_APIError_returnsError() async {
        mockServiceClient._stubbedSendResponse = .failure(TestError.fakeNetwork)
        let result = await sut.termsAndConditions(path: "/api/content/guidance/govuk-app-terms-and-conditions")

        let error = result.getError()
        #expect(error == .apiUnavailable)
    }

    @Test
    func fetchAppConfig_invalidJSON_returnsError() async {
        let mockJsonData = Data.loadFixture("MockTermsAndConditionsResponseInvalid")
        mockServiceClient._stubbedSendResponse = .success(mockJsonData)
        let result = await sut.termsAndConditions(path: "/api/content/guidance/govuk-app-terms-and-conditions")
        let unwrappedResult = result.getError()
        #expect(unwrappedResult == .parsingError)
    }
}
