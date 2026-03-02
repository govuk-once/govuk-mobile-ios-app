import Foundation
import GovKit

extension GOVRequest {
    static func search(term: String) -> GOVRequest {
        GOVRequest(
            urlPath: Constants.API.defaultSearchPath,
            method: .get,
            body: nil,
            queryParameters: ["q": term, "count": "10"],
            additionalHeaders: nil,
            requiresAuthentication: false
        )
    }

    static func searchSuggestions(term: String) -> GOVRequest {
        GOVRequest(
            urlPath: Constants.API.searchSuggestionsPath,
            method: .get,
            body: nil,
            queryParameters: ["q": term],
            additionalHeaders: nil,
            requiresAuthentication: false
        )
    }
}
