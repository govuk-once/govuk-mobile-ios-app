struct SubscriptionRequest: Codable {
    enum SubscriptionType: String, Codable {
        case notification = "Notification"
    }

    enum SubscriptionAction: String, Codable {
        case join = "Join"
    }

    enum SubscriptionGroup: String, Codable {
        case DAILY = "daily"
    }

    let namespace: String
    let group: String
    let subgroup: SubscriptionGroup
    let type: SubscriptionType
    let action: SubscriptionAction

    enum CodingKeys: String, CodingKey {
        case namespace = "Namespace"
        case group = "Group"
        case subgroup = "Subgroup"
        case type = "Type"
        case action = "Action"
    }
}
