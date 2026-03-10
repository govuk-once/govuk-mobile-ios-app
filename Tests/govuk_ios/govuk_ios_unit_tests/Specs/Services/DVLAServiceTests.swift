import Foundation
import Testing

@testable import govuk_ios

@Suite
final class DVLAServiceTests {

    var mockDVLAServiceClient: MockDVLAServiceClient!

    init() {
        mockDVLAServiceClient = MockDVLAServiceClient()
    }

    @Test
    func linkAccount_success_returnsExpectedResult() {
        mockDVLAServiceClient._stubbedLinkAccountResult = .success(())
        let sut = DVLAService(dvlaServiceClient: mockDVLAServiceClient)
        var wasSuccessful = false
        sut.linkAccount(linkId: "test-link-id") { result in
            switch result {
            case .success:
                wasSuccessful = true
            case .failure:
                Issue.record("Expected success")
            }
        }
        #expect(wasSuccessful == true)
    }

    @Test
    func linkAccount_failure_returnsExpectedError() {
        mockDVLAServiceClient._stubbedLinkAccountResult = .failure(DVLAError.authenticationError)
        let sut = DVLAService(dvlaServiceClient: mockDVLAServiceClient)
        sut.linkAccount(linkId: "test-link-id") { result in
            #expect(result.getError() == .authenticationError)
        }
    }

    
}

