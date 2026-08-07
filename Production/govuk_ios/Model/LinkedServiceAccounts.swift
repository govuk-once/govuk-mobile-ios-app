import Foundation

struct LinkedServiceAccounts: Codable {
    let services: [ServiceAccountType]

    enum CodingKeys: String, CodingKey {
        case services
    }

    init(services: [ServiceAccountType]) {
        self.services = services
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let servicesStrings = try container.decode([String].self, forKey: .services)
        self.services = servicesStrings.compactMap { ServiceAccountType(rawValue: $0) }
    }
}
