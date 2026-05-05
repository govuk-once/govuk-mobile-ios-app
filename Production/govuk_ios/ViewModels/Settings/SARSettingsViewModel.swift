import Foundation
import GovKit
import GovKitUI

class SARSettingsViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceInterface
    private var sarAction: (() -> Void)

    init(analyticsService: AnalyticsServiceInterface,
         sarAction: @escaping (() -> Void)) {
        self.analyticsService = analyticsService
        self.sarAction = sarAction
    }

    var title: String {
        String(localized: .Settings.sarTitle)
    }

    var descriptionOne: LocalizedStringResource {
        .Settings.sarDescriptionOne
    }

    var descriptionTwo: LocalizedStringResource {
        .Settings.sarDescriptionTwo
    }

    var bullets: [String] {
        [
            String(localized: .Settings.sarBulletOne),
            String(localized: .Settings.sarBulletTwo)
        ]
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        let buttonTitle = String(localized: .Settings.sarButtonTitle)
        return GOVUKButton.ButtonViewModel(
            localisedTitle: buttonTitle,
            action: { [weak self] in
                self?.sarAction()
                self?.trackSarEvent(buttonTitle)
            }
        )
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    private func trackSarEvent(_ title: String) {
        let event = AppEvent.buttonFunction(
            text: title,
            section: "Settings",
            action: "Request data"
        )
        analyticsService.track(event: event)
    }
}
