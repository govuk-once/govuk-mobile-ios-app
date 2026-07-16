import Foundation

public struct HomeCommerceItem: ECommerceItem {
    public let name: String
    public let listId: String
    public let listName: String
    public let index: Int
    public let itemId: String?
    public let locationId: String?

    public init(name: String,
                listId: String? = nil,
                listName: String,
                index: Int,
                itemId: String?,
                locationId: String?) {
        self.name = name
        self.listName = listName
        self.listId = listId ?? listName
        self.index = index
        self.itemId = itemId
        self.locationId = locationId
    }

    public func eventParameters() -> [String: String] {
        [
            "item_name": name,
            "index": "\(index)",
            "item_list_id": listId,
            "item_list_name": listName,
            "item_id": itemId ?? "",
            "location_id": locationId ?? ""
        ]
    }
}
