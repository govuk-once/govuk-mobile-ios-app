import Foundation

protocol LocalWasteServiceInterface {
    func fetchAddresses(
        postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress]
    func fetchAddress() -> LocalWasteAddress?
    func saveAddress(_ address: LocalWasteAddress)
}

class LocalWasteService: LocalWasteServiceInterface {
    private let serviceClient: LocalWasteServiceClientInterface
    private let repository: LocalWasteRepositoryInterface

    init(serviceClient: LocalWasteServiceClientInterface,
         repository: LocalWasteRepositoryInterface) {
        self.serviceClient = serviceClient
        self.repository = repository
    }

    func fetchAddresses(
        postcode: String) async throws(LocalWasteAddressSearchError) -> [LocalWasteAddress] {
        try await serviceClient.fetchAddresses(postcode: postcode)
    }

    func fetchAddress() -> LocalWasteAddress? {
        repository.fetchAddress()
    }

    func saveAddress(_ address: LocalWasteAddress) {
        repository.saveAddress(address)
    }
}
