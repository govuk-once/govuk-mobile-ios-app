import Foundation
import GovKit
import SwiftUI

class StoredLocalAuthorityWidgetViewModel {
    private let analyticsService: AnalyticsServiceInterface
    private let localAuthorityService: LocalAuthorityServiceInterface
    private let openURLAction: (URL) -> Void
    private let deleteCompletion: () -> Void
    private let openEditViewAction: () -> Void
    let localAuthorities: [LocalAuthorityItem]

    let removeLocalAuthorityButtonTitle = String(
        localized: .LocalAuthority.removeLocalAuthorityButtonTitle
    )
    let changeLocalAuthorityButtonTitle = String(
        localized: .LocalAuthority.changeLocalAuthorityButtonTitle
    )
    var removeLocalAuthorityAlertTitle: String {
        localAuthorities.count > 1 ?
        String(localized: .LocalAuthority.removeLocalAuthoritiesAlertTitle) :
        String(localized: .LocalAuthority.removeLocalAuthorityAlertTitle)
    }

    init(analyticsService: AnalyticsServiceInterface,
         localAuthorityService: LocalAuthorityServiceInterface,
         localAuthorities: [LocalAuthorityItem],
         openURLAction: @escaping (URL) -> Void,
         openEditViewAction: @escaping () -> Void,
         deleteCompletion: @escaping () -> Void
    ) {
        self.analyticsService = analyticsService
        self.localAuthorityService = localAuthorityService
        self.localAuthorities = localAuthorities
        self.openURLAction = openURLAction
        self.openEditViewAction = openEditViewAction
        self.deleteCompletion = deleteCompletion
    }

    func open(item: StoredLocalAuthorityCardModel) {
        guard let url = URL(string: item.homepageUrl) else { return }
        openURLAction(url)
        trackNavigationEvent(item.name, external: true)
    }

    func cardModels() -> [StoredLocalAuthorityCardModel] {
        localAuthorities.reduce(into: []) { partialResult, localAuthority in
            let localAuthorityDescription = localAuthorities.count > 1 ?
            returnCardDescription(authority: localAuthority) : nil
            let card = StoredLocalAuthorityCardModel(
                name: localAuthority.name,
                homepageUrl: localAuthority.homepageUrl,
                description: localAuthorityDescription
            )
            partialResult.append(card)
        }
    }

    func deleteAction() {
        localAuthorityService.deleteLocalAuthorities { [weak self] in
            DispatchQueue.main.async {
                self?.deleteCompletion()
            }
        }

        let event = AppEvent.buttonFunction(
            text: removeLocalAuthorityButtonTitle,
            section: "Local",
            action: "Remove"
        )
        analyticsService.track(event: event)
    }

    func changeAction() {
        openEditViewAction()

        let event = AppEvent.buttonFunction(
            text: changeLocalAuthorityButtonTitle,
            section: "Local",
            action: "Change"
        )
        analyticsService.track(event: event)
    }

    private func returnCardDescription(authority: LocalAuthorityItem) -> String {
        authority.parent != nil ?
        String(localized: .LocalAuthority.localAuthorityTwoTierChildDescription) :
        String(localized: .LocalAuthority.localAuthorityTwoTierParentDescription)
    }

    private func trackNavigationEvent(_ title: String,
                                      external: Bool) {
        let event = AppEvent.widgetNavigation(
            text: title,
            external: external
        )
        analyticsService.track(event: event)
    }
}
