import Foundation

@testable import govuk_ios

extension ServiceAccountLinkStatus {
    static var arrangeLinked: ServiceAccountLinkStatus {
        .arrange(linked: true)
    }

    static var arrangeUnlinked: ServiceAccountLinkStatus {
        .arrange(linked: false)
    }

    static func arrange(
        linked: Bool = true
    ) -> ServiceAccountLinkStatus {
        .init(linked: linked)
    }
}
