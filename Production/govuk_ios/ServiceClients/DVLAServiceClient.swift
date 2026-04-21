import Foundation

typealias DrivingLicenceResult = Result<DrivingLicence, DVLAError>
typealias DriverSummaryResult = Result<DriverSummary, DVLAError>

protocol DVLAServiceClientInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchDriverSummary() async -> DriverSummaryResult
}

class DVLAServiceClient: DVLAServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface

    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchDrivingLicence() async -> DrivingLicenceResult {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: .drivingLicence,
                completion: {
                    continuation.resume(
                        returning: self.mapResult($0)
                    )
                }
            )
        }
    }

    func fetchDriverSummary() async -> DriverSummaryResult {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: .driverSummary,
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
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

                let response = try jsonDecoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(DVLAError.decodingError)
            }
        }
    }
}
