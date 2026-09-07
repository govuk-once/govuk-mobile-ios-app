import Foundation

extension URLComponents {
    func caseInsensitiveQueryParam(for key: String) -> String? {
        queryItems?.first { $0.name.lowercased() == key }?.value?.lowercased()
    }
}
