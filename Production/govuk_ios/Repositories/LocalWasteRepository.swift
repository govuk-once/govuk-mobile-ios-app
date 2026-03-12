import Foundation
import CoreData
import GovKit

protocol LocalWasteRepositoryInterface {
    func saveAddress(_ address: LocalWasteAddress)
    func fetchAddress() -> LocalWasteAddress?
}

struct LocalWasteRepository: LocalWasteRepositoryInterface {
    private let coreData: CoreDataRepositoryInterface

    init(coreData: CoreDataRepositoryInterface) {
        self.coreData = coreData
    }

    func saveAddress(_ address: LocalWasteAddress) {
        let context = coreData.backgroundContext
        var oldAddresses = [LocalWasteAddressItem]()

        context.performAndWait {
            oldAddresses = fetch(context: context)
        }
        oldAddresses.forEach {
            context.delete($0)
        }

        let newAddress = LocalWasteAddressItem(context: context)
        newAddress.update(with: address)

        try? context.save()
    }

    func fetchAddress() -> LocalWasteAddress? {
        fetch(context: coreData.viewContext).first?.toDomain()
    }

    private func fetch(context: NSManagedObjectContext) -> [LocalWasteAddressItem] {
        let fetchRequest = LocalWasteAddressItem.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
}

extension LocalWasteAddressItem {
    func toDomain() -> LocalWasteAddress {
        LocalWasteAddress(
            addressFull: addressFull,
            uprn: uprn,
            localCustodianCode: localCustodianCode)
    }
}
