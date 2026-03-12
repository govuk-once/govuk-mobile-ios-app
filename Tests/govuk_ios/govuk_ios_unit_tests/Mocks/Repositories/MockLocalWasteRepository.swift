import Foundation

@testable import govuk_ios

final class MockLocalWasteRepository: LocalWasteRepositoryInterface {
    var _didSaveAddress = false
    func saveAddress(_ address: LocalWasteAddress) {
        _didSaveAddress = true
    }

    var _didFetchAddress = false
    func fetchAddress() -> LocalWasteAddress? {
        _didFetchAddress = true
        return nil
    }
}
