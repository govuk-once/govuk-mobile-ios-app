import Foundation

struct GOVRequest {
    let urlPath: String
    let method: Method
    let bodyParameters: [String: Any]?
    let queryParameters: [String: String?]?
    let additionalHeaders: [String: String]?
    var signingKey: String?
    var requiresAuthentication: Bool
}

enum Method: String {
    case get
    case post
    case delete
    case put
    case patch
}
