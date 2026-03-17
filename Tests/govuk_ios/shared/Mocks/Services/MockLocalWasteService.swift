import Foundation

@testable import govuk_ios

class MockLocalWasteService: LocalWasteServiceInterface {
    
    var _dataFetchAddresses: [LocalWasteAddress]?
    var _errorFetchAddresses: LocalWasteAddressesApiError?
    var _postcodeFetchAddresses: String?
    var _fetchAddressesPreCall: (() -> Void)?
    func fetchAddresses(
        postcode: String
    ) async throws(LocalWasteAddressesApiError) -> [LocalWasteAddress] {
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
    
    var _dataFetchSchedule: [LocalWasteBin]?
    var _errorFetchSchedule: LocalWasteScheduleApiError?
    var _uprnFetchSchedule: String?
    var _localCustodianCodeFetchSchedule: String?
    var _fetchSchedulePreCall: (() -> Void)?
    func fetchSchedule(
        uprn: String,
        localCustodianCode: String
    ) async throws(LocalWasteScheduleApiError) -> [LocalWasteBin] {
        if let preCallAction = _fetchSchedulePreCall {
            preCallAction()
        }
        _uprnFetchSchedule = uprn
        _localCustodianCodeFetchSchedule = localCustodianCode
        if let result = _dataFetchSchedule {
            return result
        }
        if let error = _errorFetchSchedule {
            throw error
        }
        abort()
    }
}
