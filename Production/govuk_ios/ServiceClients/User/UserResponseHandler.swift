import Foundation

struct UserResponseHandler: ResponseHandler {
    func handleStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        case 401, 403:
            UserStateError.authenticationError
        default:
            UserStateError.apiUnavailable
        }
    }
}
