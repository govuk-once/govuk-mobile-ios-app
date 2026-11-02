import Foundation

struct DVLAErrorPayload: Codable {
    let error: ErrorDetail
    struct ErrorDetail: Codable {
        let code: String
        let message: String
    }
}

struct DVLAResponseHandler: ResponseHandler {
    func parseError(from data: Data, statusCode: Int) -> Error? {
        guard let errorPayload = try? JSONDecoder().decode(DVLAErrorPayload.self, from: data) else {
            return nil
        }
        return DVLAResponseError.apiError(
            DVLAAPIErrorDetail(
                code: errorPayload.error.code,
                message: errorPayload.error.message,
                statusCode: statusCode
            )
        )
    }

    func handleStatusCode(_ statusCode: Int) -> Error {
        DVLAResponseError.httpError(statusCode: statusCode)
    }
}
