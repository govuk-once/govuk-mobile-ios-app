import Foundation

typealias DrivingLicenceResult = Result<DrivingLicence, DVLADomainError>
typealias CustomerVehiclesResult = Result<CustomerVehicles, DVLADomainError>
typealias CustomerVehicleDetailsResult = Result<CustomerVehicleDetails, DVLADomainError>
typealias VehicleResult = Result<VehicleEnquiryResponse, DVLADomainError>
typealias ShareCodesResult = Result<ShareCodeListResponse, DVLADomainError>
typealias ShareCodeResult = Result<ShareCodeResponse, DVLADomainError>

protocol DVLAServiceClientInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchCustomerVehicles() async -> CustomerVehiclesResult
    func fetchCustomerVehicleDetails(_ vehicleID: Int) async -> CustomerVehicleDetailsResult
    func fetchVehicle(registration: String) async -> VehicleResult
    func fetchShareCodes() async -> ShareCodesResult
    func createShareCode() async -> ShareCodeResult
    func cancelShareCode(id: String) async -> ShareCodeResult
}

class DVLAServiceClient: DVLAServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface

    private let licenceMapping = LicenceErrorMapping()
    private let vehicleEnquiryMapping = VehicleEnquiryErrorMapping()

    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchDrivingLicence() async -> DrivingLicenceResult {
        let result: Result<DrivingLicenceResponse, DVLADomainError> =
            await performRequest(.drivingLicence, errorMapping: licenceMapping)
        return result.map { $0.customerDrivingLicence }
    }

    func fetchCustomerVehicles() async -> CustomerVehiclesResult {
        await performRequest(.customerVehicles, errorMapping: licenceMapping)
    }

    func fetchCustomerVehicleDetails(_ vehicleID: Int) async -> CustomerVehicleDetailsResult {
        await performRequest(.customerVehicleDetails(vehicleID), errorMapping: licenceMapping)
    }

    func fetchVehicle(registration: String) async -> VehicleResult {
        await performRequest(
            .vehicle(registration: registration),
            errorMapping: vehicleEnquiryMapping
        )
    }

    func fetchShareCodes() async -> ShareCodesResult {
        await performRequest(.listShareCodes, errorMapping: licenceMapping)
    }

    func createShareCode() async -> ShareCodeResult {
        await performRequest(.createShareCode, errorMapping: licenceMapping)
    }

    func cancelShareCode(id: String) async -> ShareCodeResult {
        await performRequest(.cancelShareCode(id: id), errorMapping: licenceMapping)
    }

    private func performRequest<T: Decodable>(
        _ request: GOVRequest,
        errorMapping: DomainErrorMapping
    ) async -> Result<T, DVLADomainError> {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: request,
                completion: {
                    continuation.resume(
                        returning: self.mapResult($0, errorMapping: errorMapping)
                    )
                }
            )
        }
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>,
        errorMapping: DomainErrorMapping
    ) -> Result<T, DVLADomainError> {
        return result.mapError { error in
            if let urlError = error as? URLError {
                if urlError.code == .notConnectedToInternet {
                    return DVLADomainError.networkUnavailable
                }
                return DVLADomainError.serviceUnavailable(statusCode: nil)
            }

            if let responseError = error as? DVLAResponseError {
                switch responseError {
                case .apiError(let detail):
                    return errorMapping.mapAPIError(detail)
                case .httpError(let statusCode):
                    return errorMapping.mapHTTPError(statusCode: statusCode)
                }
            }

            return DVLADomainError.serviceUnavailable(statusCode: nil)
        }.flatMap {
            do {
                let response = try decoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                assertionFailure("DVLA decoding failed: \(error)")
                return .failure(DVLADomainError.decodingError)
            }
        }
    }

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        let shortDateFormatter = DateFormatter()
            shortDateFormatter.dateFormat = "yyyy-MM-dd"
            shortDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            shortDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = shortDateFormatter.date(from: dateString) {
                return date
            } else if let date = isoFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown date format: \(dateString)")
        }
        return decoder
    }()
}
