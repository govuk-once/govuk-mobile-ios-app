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
        var date: Date?

        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        date = formatterWithFractional.date(from: rawLastUpdate)

        if date == nil {
            let formatterWithoutFractional = ISO8601DateFormatter()
            formatterWithoutFractional.formatOptions = [.withInternetDateTime]
            date = formatterWithoutFractional.date(from: rawLastUpdate)
        }

        guard let date = date else {
            return rawLastUpdate
        }
        return date.formatToRelativeDate()
    }
}
