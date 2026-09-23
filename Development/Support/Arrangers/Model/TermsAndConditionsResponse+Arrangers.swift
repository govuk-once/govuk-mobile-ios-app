#if DEBUG
import Foundation

extension TermsAndConditionsResponse {
    static func arrange(fileName: String) -> TermsAndConditionsResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(
            from: .load(filename: fileName)
        )
    }
}
#endif // DEBUG
