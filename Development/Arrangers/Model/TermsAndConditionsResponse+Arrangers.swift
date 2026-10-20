import Foundation

extension TermsAndConditionsResponse {
    static func arrange(fileName: String) -> TermsAndConditionsResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(
            from: Data.loadFixture(fileName)
        )
    }
}
