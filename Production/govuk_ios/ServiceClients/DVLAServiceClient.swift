import Foundation

typealias DrivingLicenceResult = Result<DrivingLicence, DVLAError>
typealias CustomerVehiclesResult = Result<CustomerVehicles, DVLAError>
typealias CustomerVehicleDetailsResult = Result<CustomerVehicleDetails, DVLAError>
typealias VehicleResult = Result<VehicleEnquiryResponse, DVLAError>
typealias ShareCodesResult = Result<ShareCodeListResponse, DVLAError>
typealias ShareCodeResult = Result<ShareCodeResponse, DVLAError>

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

    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchDrivingLicence() async -> DrivingLicenceResult {
        let result: Result<DrivingLicenceResponse, DVLAError> =
            await performRequest(.drivingLicence)
        return result.map { $0.customerDrivingLicence }
    }

    func fetchCustomerVehicles() async -> CustomerVehiclesResult {
        await performRequest(.customerVehicles)
    }

    func fetchCustomerVehicleDetails(_ vehicleID: Int) async -> CustomerVehicleDetailsResult {
        await performRequest(.customerVehicleDetails(vehicleID))
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

    private func performRequest<T: Decodable>(
        _ request: GOVRequest
    ) async -> Result<T, DVLAError> {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: request,
                completion: {
                    let result: Result<T, DVLAError> = self.mapResult($0)
                    continuation.resume(
                        returning: result
                    )
                }
            )
        }
    }

    private func origPerformRequest<T: Decodable>(
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

// KK_TODO: uncomment the following method
//       currently replaced in an extension below for test/demo purposes

//    private func mapResult<T: Decodable>(
//        _ result: NetworkResult<Data>
//    ) -> Result<T, DVLAError> {
//        return result.mapError { error in
//            let nsError = (error as NSError)
//            if nsError.code == NSURLErrorNotConnectedToInternet {
//                return DVLAError.networkUnavailable
//            } else {
//                return (error as? DVLAError) ?? DVLAError.apiUnavailable
//            }
//        }.flatMap {
//            do {
//                let response = try decoder.decode(T.self, from: $0)
//                return .success(response)
//            } catch {
//                return .failure(DVLAError.decodingError)
//            }
//        }
//    }

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

// KK_TODO: Nuke all of the following
// MARK: - Code for Testing and dev
extension DVLAServiceClient {
    // KK_TODO: delete this and uncomment the real method in the main class definition
    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, DVLAError> {
        if T.self == CustomerVehicles.self {
            // return my own govuk_ios.CustomerVehicles
            let fauxResponse = CustomerVehicles(customerVehicles: testData)
            if let genericFauxResponse = fauxResponse as? T {
                return .success(genericFauxResponse)
            }
        }

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

    public static func arrange(_ string: String = "01/02/1993",
                               format: String = "dd/MM/yyyy") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    private var testData: [CustomerVehicles.Vehicle] {
        [
            // expired | untaxed
            CustomerVehicles.Vehicle(vehicleId: 102088978,
                                     registrationNumber: "VX58 ABK",
                                     make: "VAUXHALL",
                                     model: "WYVERN",
                                     motStatus: "No details held by DVLA",
                                     taxStatus: .untaxed,
                                     dateOfLiability: nil,
                                     sornStart: nil,
                                     taxedUntil: DVLAServiceClient.arrange("12/12/2026"),
                                     motExpiryDate: DVLAServiceClient.arrange("12/12/2030"),
                                     currentLicencePaymentMethod: nil),
            // not taxed for road use: not needed | no tax to pay
            CustomerVehicles.Vehicle(vehicleId: 102088979,
                                     registrationNumber: "VX58 ABK",
                                     make: "VAUXHALL",
                                     model: "WYVERN",
                                     motStatus: "No details held by DVLA",
                                     taxStatus: .notTaxedForOnRoadUse,
                                     dateOfLiability: nil,
                                     sornStart: nil,
                                     taxedUntil: nil,
                                     motExpiryDate: nil,
                                     currentLicencePaymentMethod: nil),
            // unknown | not found -  contact dvla
            CustomerVehicles.Vehicle(vehicleId: 102088981,
                                     registrationNumber: "VX58 ABK",
                                     make: "VAUXHALL",
                                     model: "WYVERN",
                                     motStatus: "No details held by DVLA",
                                     taxStatus: nil,
                                     dateOfLiability: nil,
                                     sornStart: nil,
                                     taxedUntil: nil,
                                     motExpiryDate: nil,
                                     currentLicencePaymentMethod: nil),
        ]
    }
}
