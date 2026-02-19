import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct GOVRequest_UserTests {
    @Test
    func userState_returnsExpectedValues() {
        let request = GOVRequest.userState

        #expect(request.urlPath == "/app/v1/user")
        #expect(request.method == .get)
        #expect(request.requiresAuthentication == true)
    }

    @Test
    func setNotificationsConsent_accepted_returnsExpectedValues() {
        let request = GOVRequest.setNotificationsConsent(consentStatus: .accepted)

        #expect(request.urlPath == "/app/v1/user/preferences")
        #expect(request.method == .patch)
        #expect(request.requiresAuthentication == true)
        let expectedBodyParameters: [String: AnyHashable] = [
            "notifications": [
                "consentStatus": "accepted"
            ]
        ]
        #expect(request.bodyParameters as? [String: AnyHashable] == expectedBodyParameters)
    }

    @Test
    func setNotificationsConsent_denied_returnsExpectedValues() {
        let request = GOVRequest.setNotificationsConsent(consentStatus: .denied)

        #expect(request.urlPath == "/app/v1/user/preferences")
        #expect(request.method == .patch)
        #expect(request.requiresAuthentication == true)
        let expectedBodyParameters: [String: AnyHashable] = [
            "notifications": [
                "consentStatus": "denied"
            ]
        ]
        #expect(request.bodyParameters as? [String: AnyHashable] == expectedBodyParameters)
    }
}
