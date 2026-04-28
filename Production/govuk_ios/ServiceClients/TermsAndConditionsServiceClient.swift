import Foundation

enum TermsAndConditionsError: LocalizedError {
    case networkUnavailable
    case apiUnavailable
    case parsingError
}

protocol TermsAndConditionsServiceClientInterface {
    func termsAndConditions(path: String) async ->
    Result<TermsAndConditionsResponse, TermsAndConditionsError>
}

class TermsAndConditionsServiceClient: TermsAndConditionsServiceClientInterface {
    private let serviceClient: APIServiceClientInterface

    init(serviceClient: APIServiceClientInterface) {
        self.serviceClient = serviceClient
    }

    func termsAndConditions(
        path: String
    ) async -> Result<TermsAndConditionsResponse, TermsAndConditionsError> {
        let request = GOVRequest.termsAndConditions(path: path)
        return await withCheckedContinuation { continuation in
            serviceClient.send(request: request) { [weak self] result in
                guard let self else { return }
                let mappedResult = self.mapResult(result)
                continuation.resume(returning: mappedResult)
            }
        }
    }

    private func mapResult(
        _ result: NetworkResult<Data>
    ) -> Result<TermsAndConditionsResponse, TermsAndConditionsError> {
        return result.mapError { error in
            let nsError = (error as NSError)
            if nsError.code == NSURLErrorNotConnectedToInternet {
                return TermsAndConditionsError.networkUnavailable
            } else {
                return TermsAndConditionsError.apiUnavailable
            }
        }.flatMap {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let contentItem: TermsAndConditionsResponse = try decoder.decode(from: $0)
                return .success(contentItem)
            } catch {
                return .failure(TermsAndConditionsError.parsingError)
            }
        }
    }
}
