struct Country: Codable, Equatable {
    let country: String
    let slug: String
    let lastUpdate: String
    let synonyms: [String]
}
