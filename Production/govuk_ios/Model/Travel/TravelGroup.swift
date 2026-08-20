import Foundation

struct TravelGroup: Codable, Equatable {
    let namespace: String
    let group: String
    let subgroup: String

    enum CodingKeys: String, CodingKey {
        case namespace = "Namespace"
        case group = "Group"
        case subgroup = "Subgroup"
    }
}
