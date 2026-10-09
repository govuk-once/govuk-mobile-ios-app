struct SubscriptionRequest: Codable {
    enum SubscriptionType: String, Codable {
        case notification = "NOTIFICATION"
    }

    enum SubscriptionAction: String, Codable {
        case join = "JOIN"
        case leave = "LEAVE"
    }

    enum SubscriptionGroup: String, Codable {
        case INSTANT = "instant"
        case NONE = "none"
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
