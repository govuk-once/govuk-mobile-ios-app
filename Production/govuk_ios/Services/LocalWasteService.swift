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

    func pushScheduleCache(_ schedule: [LocalWasteBin]?)
    func popScheduleCache() -> [LocalWasteBin]?
}

class LocalWasteService: LocalWasteServiceInterface {
    private let serviceClient: LocalWasteServiceClientInterface
    private let repository: LocalWasteRepositoryInterface

    private var scheduleCache: [LocalWasteBin]?

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
        try await serviceClient.fetchSchedule(
            uprn: uprn,
            localCustodianCode: localCustodianCode
        )
    }

    // In a production implementation, we'd build a proper cache in the repository
    // with invalidation, reloading etc.
    // For the purposes of the POC, just stash it in memory and clear it manually.

    func pushScheduleCache(_ schedule: [LocalWasteBin]?) {
        scheduleCache = schedule
    }

    func popScheduleCache() -> [LocalWasteBin]? {
        let schedule = scheduleCache
        scheduleCache = nil
        return schedule
    }
}
