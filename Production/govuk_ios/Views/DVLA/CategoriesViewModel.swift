import SwiftUI

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var entitledToDrive: [EntitlementRow] = []
    @Published private(set) var provisionallyEntitledToDrive: [EntitlementRow] = []
    @Published private(set) var links: [CategoryLink] = []

    /// Configures visual tap highlight on rows
    let showsRowHighlight: Bool

    private let didSelectAtion: ((EntitlementRow) -> Void)?
    private let onOpenURL: ((URL) -> Void)?
    private let onAnalyticsEvent: ((String, [String: Any]) -> Void)?

    init(
        entitledToDrive: [EntitlementRow] = [],
        provisionallyEntitledToDrive: [EntitlementRow] = [],
        links: [CategoryLink] = [],
        showsRowHighlight: Bool = true,
        onRowSelected: ((EntitlementRow) -> Void)? = nil,
        onOpenURL: ((URL) -> Void)? = nil,
        onAnalyticsEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.entitledToDrive = entitledToDrive
        self.provisionallyEntitledToDrive = provisionallyEntitledToDrive
        self.links = links
        self.showsRowHighlight = showsRowHighlight
        self.didSelectAtion = onRowSelected
        self.onOpenURL = onOpenURL
        self.onAnalyticsEvent = onAnalyticsEvent
    }

    convenience init(
        entitlements: [Entitlement],
        mapper: EntitlementMapping = EntitlementMapper(),
        links: [CategoryLink] = [],
        showsRowHighlight: Bool = true,
        onRowSelected: ((EntitlementRow) -> Void)? = nil,
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

    func onRowTap(_ row: EntitlementRow) {
        onAnalyticsEvent?("licence_category_row_tapped", [
            "title": row.title,
            "codes": row.codesDisplay
        ])

        didSelectAtion?(row)
    }

    func onLinkClick(_ link: CategoryLink) {
        onAnalyticsEvent?("licence_categories_link_tapped", [
            "title": link.text,
            "destination": link.url.absoluteString
        ])

        if let onOpenURL {
            onOpenURL(link.url)
        } else {
            UIApplication.shared.open(link.url)
        }
    }
}
