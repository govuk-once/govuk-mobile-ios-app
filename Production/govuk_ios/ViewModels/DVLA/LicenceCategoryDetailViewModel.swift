import Foundation
import GovKit

struct RestrictionDisplayRow: Identifiable {
    let id: String
    let code: String
    let description: String
}

class LicenceCategoryDetailViewModel: ObservableObject {
    private let dateFormatter: DateFormatter = .dvlaAccount
    private let analyticsService: AnalyticsServiceInterface
    private let entitlement: Entitlement
    private let displayMetadata: LicenceCategoryDisplayMetadata
    private let dismissAction: () -> Void

    let restrictionRows: [RestrictionDisplayRow]

    var categoryGroupTitle: String {
        displayMetadata.group.title
    }

    var categoryIcon: ImageResource? {
        displayMetadata.image
    }

    var categoryCode: String {
        displayMetadata.displayName
    }

    var validFrom: String {
        dateFormatter.string(from: entitlement.fromDate)
    }

    var validTo: String {
        dateFormatter.string(from: entitlement.expiryDate)
    }

    var categoryDescription: String {
        entitlement.categoryLegalLiteral
    }

    init(entitlement: Entitlement,
         analyticsService: AnalyticsServiceInterface,
         dismissAction: @escaping () -> Void) {
        self.entitlement = entitlement
        self.analyticsService = analyticsService
        self.dismissAction = dismissAction
        displayMetadata = LicenceCategoryDisplayMetadataBuilder.metadata(
            for: entitlement.categoryCode
        )
        self.restrictionRows = entitlement.restrictions.map {
            .init(
                id: UUID().uuidString,
                code: $0.restrictionCode,
                description: $0.restrictionLiteral
            )
        }
    }

    func dismiss() {
        trackDismissEvent()
        dismissAction()
    }

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
}
