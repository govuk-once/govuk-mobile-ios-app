import Foundation

public struct ChatExampleQuestionItem: ECommerceItem {
    public let name: String
    public let listId: String
    public let index: Int

    public init(name: String,
                listId: String,
                index: Int) {
        self.name = name
        self.listId = listId
        self.index = index
    }

    public func eventParameters() -> [String: String] {
        [
            "item_name": name,
            "index": "\(index)",
            "item_list_id": listId,
            "item_list_name": listId
        ]
    }
}
