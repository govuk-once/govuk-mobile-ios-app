import Foundation

@testable import govuk_ios

extension TermsAndConditionsResponse {
    static func arrange(fileName: String) -> TermsAndConditionsResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(
            from: .load(filename: fileName)
        )
    }
}
