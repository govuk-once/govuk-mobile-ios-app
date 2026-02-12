//


struct NotificationCentreResponseHandler: ResponseHandler {
    func handleStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        case 401, 403:
            NotificationCentreError.authenticationError
        case 404:
            NotificationCentreError.notFound
        default:
            NotificationCentreError.apiUnavailable
        }
    }
}
