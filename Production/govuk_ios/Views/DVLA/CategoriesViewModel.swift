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
final class CategoriesViewModel: ObservableObject {
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
/*
 // KK Stuff:
        self.links = [
            CategoryLink(
                text: String(localized: .DVLA.compareOldAndNewCategories),
                url: Constants.API.defaultDvlaCategoriesCompareOldAndNewUrl
            ),
            CategoryLink(
                text: String(localized: .DVLA.vehicleWeightsExplained),
                url: Constants.API.defaultDvlaCategoriesVehicleWeightsUrl
            ),
            CategoryLink(
                text: String(localized: .DVLA.addingCategoriesToYourVehicle),
                url: Constants.API.defaultDvlaCategoriesAddingCategoriesUrl
            ),
        ]
*/
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
        didSelectAction?(entitlement)
    }

    func onLinkClick(_ link: CategoryLink) {
        // KK Stuff: Analytics
        if let openURLAction = openURLAction {
            openURLAction(link.url)
        }
    }
}
