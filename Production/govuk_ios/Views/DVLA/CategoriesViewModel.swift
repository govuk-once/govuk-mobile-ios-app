import SwiftUI

struct CategoryLink: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let url: URL
}

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var entitledToDrive: [EntitlementGroup] = []
    @Published private(set) var provisionallyEntitledToDrive: [EntitlementGroup] = []
    @Published private(set) var links: [CategoryLink] = []

    let showsRowHighlight: Bool

    private let onRowSelected: ((Entitlement) -> Void)?
    private let onOpenURL: ((URL) -> Void)?
    private let onAnalyticsEvent: ((String, [String: Any]) -> Void)?

    init(
        entitledToDrive: [EntitlementGroup] = [],
        provisionallyEntitledToDrive: [EntitlementGroup] = [],
        links: [CategoryLink] = [],
        showsRowHighlight: Bool = true,
        onRowSelected: ((Entitlement) -> Void)? = nil,
        onOpenURL: ((URL) -> Void)? = nil,
        onAnalyticsEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.entitledToDrive = entitledToDrive
        self.provisionallyEntitledToDrive = provisionallyEntitledToDrive
        self.links = links
        self.showsRowHighlight = showsRowHighlight
        self.onRowSelected = onRowSelected
        self.onOpenURL = onOpenURL
        self.onAnalyticsEvent = onAnalyticsEvent
    }

    convenience init(
        entitlements: [Entitlement],
        mapper: EntitlementMapping = EntitlementMapper(),
        links: [CategoryLink] = [],
        showsRowHighlight: Bool = true,
        onRowSelected: ((Entitlement) -> Void)? = nil,
        onOpenURL: ((URL) -> Void)? = nil,
        onAnalyticsEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        let categorised = mapper.map(entitlements: entitlements)

        self.init(
            entitledToDrive: categorised.entitledToDrive,
            provisionallyEntitledToDrive: categorised.provisionallyEntitledToDrive,
            links: links,
            showsRowHighlight: showsRowHighlight,
            onRowSelected: onRowSelected,
            onOpenURL: onOpenURL,
            onAnalyticsEvent: onAnalyticsEvent
        )
    }

    // MARK: - User Actions

    func onRowTap(_ entitlement: Entitlement) {
        let metadata = LicenceCategoryDisplayMetadataBuilder.metadata(for: entitlement.categoryCode)
        onAnalyticsEvent?("licence_category_row_tapped", [
            "code": entitlement.categoryCode,
            "display_name": metadata.displayName,
            "group": metadata.group.title
        ])

        onRowSelected?(entitlement)
    }

    func onLinkClick(_ link: CategoryLink) {
        onAnalyticsEvent?("licence_categories_link_tapped", [
            "title": link.text,
            "destination": link.url.absoluteString
        ])

        print("KK open link")
    }
}
