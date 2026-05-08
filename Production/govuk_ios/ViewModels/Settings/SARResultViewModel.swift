import Foundation
import GovKit
import GovKitUI

class SARResultViewModel: ObservableObject {
    @Published var progressOpacity = 1.0
    @Published var userState: UserState?

    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private var sarResultAction: (() -> Void)

    init(analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         sarResultAction: @escaping (() -> Void)) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.sarResultAction = sarResultAction
        fetchUserState()
    }

    var title: String {
        String(localized: .Settings.sarTitle)
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        let buttonTitle = String.common.localized("close")
        return GOVUKButton.ButtonViewModel(
            localisedTitle: buttonTitle,
            action: { [weak self] in
                self?.sarResultAction()
                self?.trackSarEvent(buttonTitle)
            }
        )
    }

    private func fetchUserState() {
        userService.fetchUserState { [weak self] userState in
            self?.progressOpacity = 0.0
            switch userState {
            case .success(let userState):
                self?.userState = userState
            case .failure(let error):
                print("user state error: \(error.localizedDescription)")
            }
        }
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
