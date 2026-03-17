import Foundation

protocol LocalWasteServiceInterface {
    func fetchAddresses(
        postcode: String
    ) async throws(LocalWasteAddressesApiError) -> [LocalWasteAddress]

    func fetchAddress() -> LocalWasteAddress?

    func saveAddress(_ address: LocalWasteAddress)

    func fetchSchedule(
        uprn: String,
        localCustodianCode: String
    ) async throws(LocalWasteScheduleApiError) -> [LocalWasteBin]
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
        postcode: String
    ) async throws(LocalWasteAddressesApiError)
    -> [LocalWasteAddress] {
        try await serviceClient.fetchAddresses(postcode: postcode)
    }

    func fetchAddress() -> LocalWasteAddress? {
        repository.fetchAddress()
    }

    func saveAddress(_ address: LocalWasteAddress) {
        repository.saveAddress(address)
    }

    func fetchSchedule(
        uprn: String,
        localCustodianCode: String
    ) async throws(LocalWasteScheduleApiError) -> [LocalWasteBin] {
        // empty
//        []
        // error
//        try? await Task.sleep(nanoseconds: 3_000_000_000)
//        throw LocalWasteScheduleApiError.apiError(.unknownError)
        // mock
        try await serviceClient.fetchSchedule(
            uprn: uprn,
            localCustodianCode: localCustodianCode
        )
    }
}
