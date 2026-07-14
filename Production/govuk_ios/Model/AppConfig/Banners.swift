import Foundation

protocol DismissibleBanner {
    var id: String { get }
}

struct AlertBanner: DismissibleBanner,
                    Decodable {
    let id: String
    let body: String
    let link: Link?
}

extension AlertBanner {
    struct Link: Decodable {
        let title: String
        let url: URL
    }
}

struct ChatBanner: DismissibleBanner,
                   Decodable {
    let id: String
    let title: String
    let body: String
    let link: Link
}

extension ChatBanner {
    struct Link: Decodable {
        let title: String
        let url: URL
    }
}

extension ChatBanner {
    func asHomeCommerceItem(index: Int) -> HomeCommerceItem {
        HomeCommerceItem(
            name: self.title,
            listName: String(describing: type(of: self)),
            index: index,
            itemId: self.id,
            locationId: self.link.url.absoluteString
        )
    }
}

struct PromoBanner: DismissibleBanner,
                    Decodable {
    let id: String
    let title: String
    let body: String
    let link: Link
    let image: String
}

extension PromoBanner {
    struct Link: Decodable {
        let title: String
        let url: URL
    }
}

extension PromoBanner {
    func asHomeCommerceItem(index: Int) -> HomeCommerceItem {
        return  HomeCommerceItem(
            name: self.title,
            listName: String(describing: type(of: self)),
            index: index,
            itemId: self.id,
            locationId: self.link.url.absoluteString
        )
    }
}

struct UserFeedbackBanner: Decodable {
    let body: String
    let link: Link
}

extension UserFeedbackBanner {
    struct Link: Decodable {
        let title: String
        let url: URL
    }
}

extension UserFeedbackBanner {
    func asHomeCommerceItem(index: Int) -> HomeCommerceItem {
        return HomeCommerceItem(
            name: self.link.title,
            listName: String(describing: type(of: self)),
            index: index,
            itemId: nil,
            locationId: self.link.url.absoluteString
        )
    }
}

enum EmergencyBannerType: String {
    case notableDeath = "notable-death"
    case nationalEmergency = "national-emergency"
    case localEmergency = "local-emergency"
    case information
}

struct EmergencyBanner: DismissibleBanner, Decodable {
    let id: String
    let title: String?
    let body: String
    let link: Link?
    let type: String?
    let allowsDismissal: Bool?
}

extension EmergencyBanner {
    struct Link: Decodable {
        let title: String
        let url: URL
    }
}

extension EmergencyBanner {
    func asHomeCommerceItem(index: Int) -> HomeCommerceItem {
        return HomeCommerceItem(
            name: self.title ?? "",
            listName: String(describing: Swift.type(of: self)),
            index: index,
            itemId: self.id,
            locationId: self.link?.url.absoluteString
        )
    }
}
