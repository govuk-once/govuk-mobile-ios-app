import Foundation

protocol LocalWasteServiceClientInterface {
    func fetchAddresses(
        postcode: String
    ) async throws(LocalWasteAddressesApiError) -> [LocalWasteAddress]

    func fetchSchedule(
        uprn: String,
        localCustodianCode: String
    ) async throws(LocalWasteScheduleApiError) -> [LocalWasteBin]
}

enum LocalWasteApiError<Message>: LocalizedError, Hashable where Message: Hashable {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case apiError(Message)
}

typealias LocalWasteAddressesApiError = LocalWasteApiError<LocalWasteAddressesErrorMessage>
typealias LocalWasteScheduleApiError = LocalWasteApiError<LocalWasteScheduleErrorMessage>

struct LocalWasteServiceClient: LocalWasteServiceClientInterface {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func fetchAddresses(
        postcode: String
    ) async throws(LocalWasteAddressesApiError) -> [LocalWasteAddress] {
        guard let url = Self.url(path: "api/address/\(postcode)") else {
            throw LocalWasteAddressesApiError.apiUnavailable
        }
        var request = URLRequest(url: url)
        request.setValue(Self.securityValue, forHTTPHeaderField: Self.securityKey)

        let (data, httpResponse): (Data, URLResponse)
        do {
            (data, httpResponse) = try await session.data(for: request)
        } catch let error as NSError where error.code == NSURLErrorNotConnectedToInternet {
            throw LocalWasteAddressesApiError.networkUnavailable
        } catch {
            throw LocalWasteAddressesApiError.apiUnavailable
        }

        guard let httpUrlResponse = httpResponse as? HTTPURLResponse else {
            throw LocalWasteAddressesApiError.apiUnavailable
        }
        switch httpUrlResponse.statusCode {
        case 200..<300:
            return try decodeLocalWasteAddresses(data)
        case 400:
            throw decodeLocalWasteAddressesError(data)
        default:
            throw LocalWasteAddressesApiError.apiUnavailable
        }
    }

    private func decodeLocalWasteAddresses(_ data: Data)
    throws(LocalWasteAddressesApiError)
    -> [LocalWasteAddress] {
        do {
            return try Self
                .jsonDecoder()
                .decode([LocalWasteAddress].self, from: data)
        } catch {
            throw LocalWasteAddressesApiError.decodingError
        }
    }

    private func decodeLocalWasteAddressesError(_ data: Data)
    -> LocalWasteAddressesApiError {
        do {
            let obj = try Self
                .jsonDecoder()
                .decode(LocalWasteAddressError.self, from: data)
            return .apiError(obj.message)
        } catch {
            return LocalWasteAddressesApiError.decodingError
        }
    }

    func fetchSchedule(
        uprn: String,
        localCustodianCode: String
    ) async throws(LocalWasteScheduleApiError) -> [LocalWasteBin] {
        guard let url = Self.url(
            path: "api/schedule?uprn=\(uprn)&localCustodianCode=\(localCustodianCode)") else {
            throw LocalWasteScheduleApiError.apiUnavailable
        }
        var request = URLRequest(url: url)
        request.setValue(Self.securityValue, forHTTPHeaderField: Self.securityKey)

        let (data, httpResponse): (Data, URLResponse)
        do {
            (data, httpResponse) = try await session.data(for: request)
        } catch let error as NSError where error.code == NSURLErrorNotConnectedToInternet {
            throw LocalWasteScheduleApiError.networkUnavailable
        } catch {
            throw LocalWasteScheduleApiError.apiUnavailable
        }

        guard let httpUrlResponse = httpResponse as? HTTPURLResponse else {
            throw LocalWasteScheduleApiError.apiUnavailable
        }
        switch httpUrlResponse.statusCode {
        case 200..<300:
            return try decodeLocalWasteSchedule(data)
        case 400:
            throw decodeLocalWasteScheduleError(data)
        default:
            throw LocalWasteScheduleApiError.apiUnavailable
        }
    }

    private func decodeLocalWasteSchedule(_ data: Data)
    throws(LocalWasteScheduleApiError)
    -> [LocalWasteBin] {
        do {
            return try Self
                .jsonDecoder()
                .decode([LocalWasteBin].self, from: data)
        } catch {
            throw LocalWasteScheduleApiError.decodingError
        }
    }

    private func decodeLocalWasteScheduleError(_ data: Data)
    -> LocalWasteScheduleApiError {
        do {
            let obj = try Self
                .jsonDecoder()
                .decode(LocalWasteScheduleError.self, from: data)
            return .apiError(obj.message)
        } catch {
            return LocalWasteScheduleApiError.decodingError
        }
    }
}

extension LocalWasteServiceClient {
    static let baseUrl = URL(string: "https://emz0rzjkva.execute-api.eu-west-2.amazonaws.com")!

    // hard-coded for the PoC
    // in a production implementation we'd be using the OAuth token
    static let securityKey = "x-api-key"
    static let securityValue = "292b66db-ab9c-459d-bfc5-d1e157a1ffc9"

    static func url(path: String) -> URL? {
        URL(string: path, relativeTo: LocalWasteServiceClient.baseUrl)
    }

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func jsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(LocalWasteServiceClient.dateFormatter)
        return decoder
    }
}
