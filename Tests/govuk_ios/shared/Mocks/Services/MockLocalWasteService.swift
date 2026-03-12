import Foundation

@testable import govuk_ios

class MockLocalWasteService: LocalWasteServiceInterface {
    
    var _dataFetchAddresses: [LocalWasteAddress]?
    var _errorFetchAddresses: LocalWasteAddressSearchError?
    var _postcodeFetchAddresses: String?
    var _fetchAddressesPreCall: (() -> Void)?
    func fetchAddresses(postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress] {
        if let preCallAction = _fetchAddressesPreCall {
            preCallAction()
        }
        _postcodeFetchAddresses = postcode
        if let result = _dataFetchAddresses {
            return result
        }
        if let error = _errorFetchAddresses {
            throw error
        }
        abort()
    }
    
    var _dataFetchAddress: LocalWasteAddress?
    func fetchAddress() -> LocalWasteAddress? {
        _dataFetchAddress
    }
    
    var _addressSaveAddress: LocalWasteAddress?
    func saveAddress(_ address: LocalWasteAddress) {
        _addressSaveAddress = address
    }
}
