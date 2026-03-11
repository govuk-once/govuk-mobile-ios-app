import Foundation

struct DVLAResponseHandler: ResponseHandler {
    func handleStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        case 401, 403:
            DVLAError.authenticationError
        default:
            DVLAError.apiUnavailable
        }
    }
}
