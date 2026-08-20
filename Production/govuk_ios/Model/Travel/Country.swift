struct Country: Codable, Equatable {
    let slug: String
    let country: String
    let lastUpdated: String
    let synonyms: [String]
}
