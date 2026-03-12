import Foundation

@testable import govuk_ios

class MockLocalWasteServiceClient: LocalWasteServiceClientInterface {
    
    var _dataFetchAddresses: [LocalWasteAddress]?
    var _errorFetchAddresses: LocalWasteAddressSearchError?
    var _postcodeFetchAddresses: String?
    func fetchAddresses(postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress] {
        _postcodeFetchAddresses = postcode
        if let result = _dataFetchAddresses {
            return result
        }
        if let error = _errorFetchAddresses {
            throw error
        }
        abort()
    }

}
