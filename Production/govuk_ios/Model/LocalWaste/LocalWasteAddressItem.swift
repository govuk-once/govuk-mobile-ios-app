import Foundation
import CoreData

@objc(LocalWasteAddressItem)
class LocalWasteAddressItem: NSManagedObject,
                             Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalWasteAddressItem> {
        return NSFetchRequest<LocalWasteAddressItem>(entityName: "LocalWasteAddressItem")
    }

    @NSManaged public var addressFull: String
    @NSManaged public var uprn: String
    @NSManaged public var localCustodianCode: String
}

extension LocalWasteAddressItem {
    func update(with address: LocalWasteAddress) {
        addressFull = address.addressFull
        uprn = address.uprn
        localCustodianCode = address.localCustodianCode
    }
}
