import Foundation

@testable import govuk_ios

class MockLocalWasteServiceClient: LocalWasteServiceClientInterface {
    
    var _dataFetchAddresses: [LocalWasteAddress]?
    var _errorFetchAddresses: LocalWasteAddressesApiError?
    var _postcodeFetchAddresses: String?
    func fetchAddresses(
        postcode: String
    ) async throws(LocalWasteAddressesApiError)
    -> [LocalWasteAddress] {
        _postcodeFetchAddresses = postcode
        if let result = _dataFetchAddresses {
            return result
        }
        if let error = _errorFetchAddresses {
            throw error
        }
        abort()
    }

    var _dataFetchSchedule: [LocalWasteBin]?
    var _errorFetchSchedule: LocalWasteScheduleApiError?
    var _uprnFetchSchedule: String?
    var _localCustodianCodeFetchSchedule: String?
    func fetchSchedule(
        uprn: String,
        localCustodianCode: String
    ) async throws(LocalWasteScheduleApiError) -> [LocalWasteBin] {
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
