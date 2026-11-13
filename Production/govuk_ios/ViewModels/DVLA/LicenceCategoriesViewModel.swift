import SwiftUI
import GovKit

struct CategoriesActions {
    let didSelectAction: ((Entitlement) -> Void)?
    let openURLAction: ((URL) -> Void)?
    let dismissAction: () -> Void
}

struct CategoryLink: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let url: URL
}

@MainActor
final class LicenceCategoriesViewModel: ObservableObject {
    @Published private(set) var entitledToDrive: [EntitlementGroup] = []
    @Published private(set) var provisionallyEntitledToDrive: [EntitlementGroup] = []
    @Published private(set) var links: [CategoryLink] = []

    private let analyticsService: AnalyticsServiceInterface

    let showsRowHighlight: Bool

    private let didSelectAction: ((Entitlement) -> Void)?
    private let openURLAction: ((URL) -> Void)?
    private let dismissAction: () -> Void

    init(
        entitledToDrive: [EntitlementGroup] = [],
        provisionallyEntitledToDrive: [EntitlementGroup] = [],
        showsRowHighlight: Bool = true,
        actions: CategoriesActions,
        links: [CategoryLink],
        analyticsService: AnalyticsServiceInterface,
    ) {
        self.entitledToDrive = entitledToDrive
        self.provisionallyEntitledToDrive = provisionallyEntitledToDrive
        self.links = links
        self.showsRowHighlight = showsRowHighlight
        self.didSelectAction = actions.didSelectAction
        self.openURLAction = actions.openURLAction
        self.dismissAction = actions.dismissAction
        self.analyticsService = analyticsService
    }

    convenience init(
        entitlements: [Entitlement],
        mapper: EntitlementMapping = EntitlementMapper(),
        showsRowHighlight: Bool = true,
        actions: CategoriesActions,
        links: [CategoryLink],
        analyticsService: AnalyticsServiceInterface
    ) {
        let categorised = mapper.map(entitlements: entitlements)

        self.init(
            entitledToDrive: categorised.entitledToDrive,
            provisionallyEntitledToDrive: categorised.provisionallyEntitledToDrive,
            showsRowHighlight: showsRowHighlight,
            actions: actions,
            links: links,
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

    func dismiss() {
        trackDismissEvent()
        dismissAction()
    }

    func onRowTap(_ entitlement: Entitlement) {
        let metadata = LicenceCategoryDisplayMetadataBuilder.metadata(for: entitlement.categoryCode)
        trackRowTapEvent()
        didSelectAction?(entitlement)
    }

    func onLinkClick(_ link: CategoryLink) {
        trackClick(link: link)
        if let openURLAction = openURLAction {
            openURLAction(link.url)
        }
    }

    // MARK: - Analytics
    func trackClick(link: CategoryLink) {
        let event = AppEvent(
            name: "Navigation",
            params: [
                "type": "Button",
                "text": link.text,
                "URL": link.url.absoluteString,
                "external": true,
                "section": "Driving"
            ]
        )
        analyticsService.track(event: event)
    }

    func trackRowTapEvent() {
        let event = AppEvent(
            name: "Navigation",
            params: [
                "type": "Button",
                "text": "Vehicle Category",
                "external": false,
                "section": "Driving"
            ]
        )
        analyticsService.track(event: event)
    }
}
