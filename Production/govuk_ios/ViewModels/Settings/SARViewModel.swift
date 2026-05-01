import Foundation
import GovKit
import GovKitUI

struct SARViewModel {
//    private var title: String
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private var sarAction: (() -> Void)

    init(analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         sarAction: @escaping (() -> Void)) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.sarAction = sarAction
    }

    private var description: String {
        String(localized: .Settings.sarDescription)
    }

    private var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        GOVUKButton.ButtonViewModel(
            localisedTitle: "Request data",
            action: sarAction
        )
    }
}
