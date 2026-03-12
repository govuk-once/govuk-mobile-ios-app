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
    func setNotificationsConsent_accepted_returnsExpectedValues() throws {
        let request = GOVRequest.setNotificationsConsent(consentStatus: .accepted)

        #expect(request.urlPath == "/app/v1/user")
        #expect(request.method == .patch)
        #expect(request.requiresAuthentication == true)

        let body = try #require(request.body as? NotificationsPreferenceUpdate)
        #expect(body.preferences.notifications.consentStatus == .accepted)
    }

    @Test
    func setNotificationsConsent_denied_returnsExpectedValues() throws {
        let request = GOVRequest.setNotificationsConsent(consentStatus: .denied)

        #expect(request.urlPath == "/app/v1/user")
        #expect(request.method == .patch)
        #expect(request.requiresAuthentication == true)

        let body = try #require(request.body as? NotificationsPreferenceUpdate)
        #expect(body.preferences.notifications.consentStatus == .denied)
    }

    @Test
    func linkAccount_returnsExpectedValues() {
        let request = GOVRequest.linkAccount(serviceName: "dvla", linkId: "test-link-id")

        #expect(request.urlPath == "/app/v1/identity/dvla/test-link-id")
        #expect(request.method == .post)
        #expect(request.requiresAuthentication == true)
    }
}
