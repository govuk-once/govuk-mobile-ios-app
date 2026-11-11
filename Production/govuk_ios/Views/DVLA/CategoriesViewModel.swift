import SwiftUI
import GovKit

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

    private let analyticsService: AnalyticsServiceInterface

    let showsRowHighlight: Bool

    private let didSelectAction: ((Entitlement) -> Void)?
    private let onOpenURL: ((URL) -> Void)?

    init(
        entitledToDrive: [EntitlementGroup] = [],
        provisionallyEntitledToDrive: [EntitlementGroup] = [],
        links: [CategoryLink] = [],
        showsRowHighlight: Bool = true,
        didSelectAction: ((Entitlement) -> Void)? = nil,
        onOpenURL: ((URL) -> Void)? = nil,
        analyticsService: AnalyticsServiceInterface,
    ) {
        self.entitledToDrive = entitledToDrive
        self.provisionallyEntitledToDrive = provisionallyEntitledToDrive
        self.links = links
        self.showsRowHighlight = showsRowHighlight
        self.didSelectAction = didSelectAction
        self.onOpenURL = onOpenURL
        self.analyticsService = analyticsService
    }

    convenience init(
        entitlements: [Entitlement],
        mapper: EntitlementMapping = EntitlementMapper(),
        links: [CategoryLink] = [],
        showsRowHighlight: Bool = true,
        didSelectAction: ((Entitlement) -> Void)? = nil,
        dismissAction: @escaping () -> Void,
        onOpenURL: ((URL) -> Void)? = nil,
        analyticsService: AnalyticsServiceInterface
    ) {
        let categorised = mapper.map(entitlements: entitlements)

        self.init(
            entitledToDrive: categorised.entitledToDrive,
            provisionallyEntitledToDrive: categorised.provisionallyEntitledToDrive,
            links: links,
            showsRowHighlight: showsRowHighlight,
            didSelectAction: didSelectAction,
            onOpenURL: onOpenURL,
            analyticsService: analyticsService
        )
    }

    // MARK: - Analytics

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    private func trackDismissEvent() {
        let event = AppEvent.buttonNavigation(
            text: "Back",
            external: false,
            section: "Driving")
        analyticsService.track(event: event)
    }


    // MARK: - User Actions

    func onRowTap(_ entitlement: Entitlement) {
        let metadata = LicenceCategoryDisplayMetadataBuilder.metadata(for: entitlement.categoryCode)
        didSelectAction?(entitlement)
    }

    func onLinkClick(_ link: CategoryLink) {
        print("KK open link")
    }
}
