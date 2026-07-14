import Foundation

struct DVLAErrorPayload: Codable {
    let errorCode: String
    let message: String
}

struct DVLAResponseHandler: ResponseHandler {
    func parseError(from data: Data) -> Error? {
        guard let errorPayload = try? JSONDecoder().decode(DVLAErrorPayload.self, from: data) else {
            return nil
        }
        switch errorPayload.errorCode {
        case "GUK-404-04":
            return DVLAError.notFound
        case "GUK-404-05":
            return DVLAError.notAvailable
        default:
            return nil
        }
    }

    func handleStatusCode(_: Int) -> Error {
        DVLAError.apiUnavailable
    }
}
