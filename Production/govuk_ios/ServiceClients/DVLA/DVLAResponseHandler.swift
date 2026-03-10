import Foundation

struct DVLAResponseHandler: ResponseHandler {
    func handleStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        case 403:
            DVLAError.authenticationError
        default:
            DVLAError.apiUnavailable
        }
    }
}
