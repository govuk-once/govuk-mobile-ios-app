import Foundation

typealias DrivingLicenceResult = Result<DrivingLicence, DVLAError>
typealias CustomerSummaryResult = Result<CustomerSummary, DVLAError>
typealias VehicleResult = Result<Vehicle, DVLAError>
typealias ShareCodesResult = Result<ShareCodeListResponse, DVLAError>
typealias ShareCodeResult = Result<ShareCodeResponse, DVLAError>
typealias IdentityVerificationResult = Result<String, DVLAError>

protocol DVLAServiceClientInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchCustomerSummary() async -> CustomerSummaryResult
    func fetchVehicle(registration: String) async -> VehicleResult
    func fetchShareCodes() async -> ShareCodesResult
    func createShareCode() async -> ShareCodeResult
    func cancelShareCode(id: String) async -> ShareCodeResult
    func fetchIdentityVerification() async -> IdentityVerificationResult
}

class DVLAServiceClient: DVLAServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface

    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchDrivingLicence() async -> DrivingLicenceResult {
        let result: Result<DrivingLicenceResponse, DVLAError> =
            await performRequest(.drivingLicence)
        return result.map { $0.customerDrivingLicence }
    }

    func fetchCustomerSummary() async -> CustomerSummaryResult {
        await performRequest(.customerSummary)
    }

    func fetchVehicle(registration: String) async -> VehicleResult {
        await performRequest(.vehicle(registration: registration))
    }

    func fetchShareCodes() async -> ShareCodesResult {
        await performRequest(.listShareCodes)
    }

    func createShareCode() async -> ShareCodeResult {
        await performRequest(.createShareCode)
    }

    func cancelShareCode(id: String) async -> ShareCodeResult {
        await performRequest(.cancelShareCode(id: id))
    }

    func fetchIdentityVerification() async -> IdentityVerificationResult {
        await performRequest(.identityVerification)
    }

    private func performRequest<T: Decodable>(
        _ request: GOVRequest
    ) async -> Result<T, DVLAError> {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: request,
                completion: {
                    continuation.resume(
                        returning: self.mapResult($0)
                    )
                }
            )
        }
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, DVLAError> {
        return result.mapError { error in
            let nsError = (error as NSError)
            if nsError.code == NSURLErrorNotConnectedToInternet {
                return DVLAError.networkUnavailable
            } else {
                return (error as? DVLAError) ?? DVLAError.apiUnavailable
            }
        }.flatMap {
            do {
                let response = try decoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(DVLAError.decodingError)
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
