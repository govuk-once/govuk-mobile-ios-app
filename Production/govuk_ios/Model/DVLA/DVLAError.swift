import Foundation

// MARK: - API error payload (parsed from DVLA response body)

struct DVLAAPIErrorDetail: Equatable, Sendable {
    let code: String
    let message: String
    let statusCode: Int
}

// MARK: - Intermediate error (travels through the untyped Error gap)

/// Produced by DVLAResponseHandler, cast back in DVLAServiceClient.mapResult.
enum DVLAResponseError: Error, Equatable {
    case apiError(DVLAAPIErrorDetail)
    case httpError(statusCode: Int)
}

// MARK: - Domain error (consumer-facing, used by view models)

enum DVLADomainError: Error, Equatable {
    case notFound(message: String? = nil)
    case notAvailable(message: String? = nil)
    case unrecognisedAPIError(DVLAAPIErrorDetail)
    case serviceUnavailable(statusCode: Int?)
    case networkUnavailable
    case decodingError
}

// MARK: - Endpoint-specific error mapping

protocol DomainErrorMapping {
    func mapAPIError(_ detail: DVLAAPIErrorDetail) -> DVLADomainError
    func mapHTTPError(statusCode: Int) -> DVLADomainError
}

struct LicenceErrorMapping: DomainErrorMapping {
    func mapAPIError(_ detail: DVLAAPIErrorDetail) -> DVLADomainError {
        switch detail.code {
        case "GUK-404-04":
            return .notFound(message: detail.message)
        case "GUK-404-05":
            return .notAvailable(message: detail.message)
        default:
            return .unrecognisedAPIError(detail)
        }
    }

    func mapHTTPError(statusCode: Int) -> DVLADomainError {
        assert(
            statusCode.isHTTPError,
            "mapHTTPError should only receive HTTP error status codes (4xx/5xx)")
        return .serviceUnavailable(statusCode: statusCode)
    }
}

struct VehicleEnquiryErrorMapping: DomainErrorMapping {
    func mapAPIError(_ detail: DVLAAPIErrorDetail) -> DVLADomainError {
        .unrecognisedAPIError(detail)
    }

    func mapHTTPError(statusCode: Int) -> DVLADomainError {
        assert(statusCode.isHTTPError,
               "mapHTTPError should only receive HTTP error status codes (4xx/5xx)")
        switch statusCode {
        case 404:
            return .notFound()
        default:
            return .serviceUnavailable(statusCode: statusCode)
        }
    }
}
