import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct AppEvent_ServiceAccountTests {
    @Test
    func linkServiceAccountNavigation_returnsExpectedResult() {
        let result = AppEvent.linkServiceAccountNavigation(title: "Test title")
        #expect(result.params?["text"] as? String == "Test title")
        #expect(result.params?["type"] as? String == "trigger card")
        #expect(result.params?["section"] as? String == "account link")
        #expect(result.name == "Navigation")
    }
}

