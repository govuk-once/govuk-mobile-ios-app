import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct GOVRequest_DVLATests {
    @Test
    func linkAccount_returnsExpectedValues() {
        let request = GOVRequest.linkAccount(linkId: "test-link-id")

        #expect(request.urlPath == "/app/v1/udp/identity/dvla/test-link-id")
        #expect(request.method == .post)
        #expect(request.requiresAuthentication == true)
    }

}
