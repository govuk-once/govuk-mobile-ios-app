import Foundation

extension HTTPURLResponse {
    var isSuccessful: Bool {
        (200..<300).contains(statusCode)
    }
}
