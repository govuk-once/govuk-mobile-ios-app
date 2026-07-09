import Foundation

typealias DrivingLicenceResult = Result<DrivingLicence, DVLAError>
typealias CustomerSummaryResult = Result<CustomerSummary, DVLAError>
typealias VehicleResult = Result<Vehicle, DVLAError>
typealias ShareCodesResult = Result<ShareCodeListResponse, DVLAError>
typealias ShareCodeResult = Result<ShareCodeResponse, DVLAError>
typealias IdentityVerificationResult = Result<VerificationResult, DVLAError>

protocol DVLAServiceClientInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchCustomerSummary() async -> CustomerSummaryResult
    func fetchVehicle(registration: String) async -> VehicleResult
    func fetchShareCodes() async -> ShareCodesResult
    func fetchIdentityVerification() async -> IdentityVerificationResult
    func createShareCode() async -> ShareCodeResult
    func cancelShareCode(id: String) async -> ShareCodeResult
}

struct VerificationResult: Decodable {
    let verificationHash: String
}

class DVLAServiceClient: DVLAServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface
    private let verificationServiceClient: APIServiceClientInterface
    private let authenticationService: AuthenticationServiceInterface

    init(apiServiceClient: APIServiceClientInterface,
         verificationServiceClient: APIServiceClientInterface,
         authenticationService: AuthenticationServiceInterface) {
        self.apiServiceClient = apiServiceClient
        self.verificationServiceClient = verificationServiceClient
        self.authenticationService = authenticationService
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

    func fetchIdentityVerification() async -> IdentityVerificationResult {
        let request = GOVRequest.identityVerification(
            token: authenticationService.accessToken ?? ""
        )
        return await performVerificationRequest(request)
    }

    func createShareCode() async -> ShareCodeResult {
        await performRequest(.createShareCode)
    }

    func cancelShareCode(id: String) async -> ShareCodeResult {
        await performRequest(.cancelShareCode(id: id))
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

    private func performVerificationRequest<T: Decodable>(
        _ request: GOVRequest
    ) async -> Result<T, DVLAError> {
        await withCheckedContinuation { continuation in
            verificationServiceClient.send(
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
