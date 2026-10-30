import Testing
@testable import govuk_ios

@Suite
struct LicenceErrorMappingTests {
    let sut = LicenceErrorMapping()

    @Test
    func mapAPIError_notFoundCode_mapsToNotFoundWithMessage() {
        let detail = DVLAAPIErrorDetail(
            code: "GUK-404-04",
            message: "Driving licence record not found",
            statusCode: 404
        )

        let result = sut.mapAPIError(detail)

        #expect(result == .notFound(message: "Driving licence record not found"))
    }

    @Test
    func mapAPIError_notAvailableCode_mapsToNotAvailableWithMessage() {
        let detail = DVLAAPIErrorDetail(
            code: "GUK-404-05",
            message: "Driving licence service temporarily unavailable",
            statusCode: 404
        )

        let result = sut.mapAPIError(detail)

        #expect(result == .notAvailable(message: "Driving licence service temporarily unavailable"))
    }

    @Test
    func mapAPIError_unrecognisedCode_mapsToUnrecognisedAPIError() {
        let detail = DVLAAPIErrorDetail(
            code: "GUK-500-01",
            message: "Internal server error",
            statusCode: 500
        )

        let result = sut.mapAPIError(detail)

        #expect(result == .unrecognisedAPIError(detail))
    }

    @Test(arguments: [400, 401, 403, 404, 500, 503])
    func mapHTTPError_mapsToServiceUnavailableWithStatusCode(statusCode: Int) {
        let result = sut.mapHTTPError(statusCode: statusCode)

        #expect(result == .serviceUnavailable(statusCode: statusCode))
    }
}

// MARK: - VehicleEnquiryErrorMapping Tests

@Suite
struct VehicleEnquiryErrorMappingTests {
    let sut = VehicleEnquiryErrorMapping()

    @Test
    func mapAPIError_alwaysReturnsUnrecognisedAPIError() {
        let detail = DVLAAPIErrorDetail(
            code: "VEHICLE_INVALID_FORMAT",
            message: "Registration format not recognized",
            statusCode: 400
        )

        let result = sut.mapAPIError(detail)

        #expect(result == .unrecognisedAPIError(detail))
    }

    @Test
    func mapHTTPError_statusCode404_mapsToNotFoundWithoutMessage() {
        let result = sut.mapHTTPError(statusCode: 404)

        #expect(result == .notFound(message: nil))
    }

    @Test(arguments: [400, 401, 403, 500, 502, 503])
    func mapHTTPError_non404StatusCodes_mapsToServiceUnavailable(statusCode: Int) {
        let result = sut.mapHTTPError(statusCode: statusCode)

        #expect(result == .serviceUnavailable(statusCode: statusCode))
    }
}
