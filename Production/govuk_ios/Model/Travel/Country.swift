import Foundation

struct Country: Codable, Equatable {
    let name: String
    let slug: String
    let rawLastUpdate: String
    let synonyms: [String]

    enum CodingKeys: String, CodingKey {
        case name = "country"
        case slug = "slug"
        case rawLastUpdate = "lastUpdate"
        case synonyms = "synonyms"
    }

    var formattedLastUpdate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: rawLastUpdate) else {
            return rawLastUpdate
        }
        return date.formatToRelativeDate()
    }
}
