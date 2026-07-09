import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LinkedServiceAccountsTests {

    private let decoder = JSONDecoder()

    @Test
    func decode_allValidServices_returnExpectedResult() throws {
        let json = """
        { 
        "services": ["dvla"] 
        }
        """.data(using: .utf8)!

        let result = try decoder.decode(LinkedServiceAccounts.self, from: json)
        #expect(result.services == [.dvla])
    }

    @Test
    func decode_someInvalidServices_ignoresUnknownServices() throws {
        let json = """
        { 
        "services": ["app","dvla"] 
        }
        """.data(using: .utf8)!

        let result = try decoder.decode(LinkedServiceAccounts.self, from: json)
        #expect(result.services == [.dvla])
    }
}
