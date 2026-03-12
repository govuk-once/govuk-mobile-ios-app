import Foundation

protocol LocalWasteServiceClientInterface {
    func fetchAddresses(postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress]
}

enum LocalWasteAddressSearchError: LocalizedError {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case unknownPostcode
    case invalidPostcode
}

struct LocalWasteServiceClient: LocalWasteServiceClientInterface {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func fetchAddresses(postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress] {
        guard let url = LocalWasteServiceClient.url(path: "api/address/\(postcode)") else {
            throw LocalWasteAddressSearchError.apiUnavailable
        }
        let request = URLRequest(url: url)
        let (data, httpResponse): (Data, URLResponse)
        
        do {
            (data, httpResponse) = try await session.data(for: request)
        } catch let error as NSError where error.code == NSURLErrorNotConnectedToInternet {
            throw LocalWasteAddressSearchError.networkUnavailable
        } catch {
            throw LocalWasteAddressSearchError.apiUnavailable
        }
        
        guard let httpUrlResponse = httpResponse as? HTTPURLResponse else {
            throw LocalWasteAddressSearchError.apiUnavailable
        }
        switch httpUrlResponse.statusCode {
        case 200..<300:
            do {
                return try LocalWasteServiceClient
                    .jsonDecoder()
                    .decode([LocalWasteAddress].self, from: data)
            } catch {
                throw LocalWasteAddressSearchError.decodingError
            }
        // TODO
        // case 400:
        //    break
        default:
            throw LocalWasteAddressSearchError.apiUnavailable
        }
    }
}

extension LocalWasteServiceClient {
    static let baseUrl = URL(string: "https://emz0rzjkva.execute-api.eu-west-2.amazonaws.com")!

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

/*
struct FakeLocalWasteServiceClient: LocalWasteServiceClientInterface {
    func fetchAddresses(postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress] {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        if postcode != "BS153FL" {
            throw LocalWasteAddressSearchError.unknownPostcode
        }
        
        return [
            LocalWasteAddress(
                addressFull: "12, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662553",
                localCustodianCode: "119"
            ),
            LocalWasteAddress(
                addressFull: "14, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662554",
                localCustodianCode: "119"
            ),
            LocalWasteAddress(
                addressFull: "15, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662564",
                localCustodianCode: "119"
            ),
            LocalWasteAddress(
                addressFull: "16, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662555",
                localCustodianCode: "119"
            )
        ]
    }
}
*/
