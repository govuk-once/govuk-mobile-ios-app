import Foundation

extension URLComponents {
    func lowercaseQueryParamValue(for key: String) -> String? {
        queryItems?.first { $0.name == key }?.value?.lowercased()
    }
}
