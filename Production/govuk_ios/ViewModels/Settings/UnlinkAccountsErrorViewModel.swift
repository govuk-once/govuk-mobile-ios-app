import SwiftUI
import GovKitUI

final class UnlinkAccountsErrorViewModel: ObservableObject {
    let title = String(
        localized: .Settings.yourAccountsUnlinkingErrorTitle
    )
    let description = String(
        localized: .Settings.yourAccountsUnlinkingErrorDescription
    )
    let errorViewDescription = String(
        localized: .Settings.yourAccountsErrorViewDesc
    )
    let buttonTitle = String(
        localized: .Settings.yourAccountsUnlinkingErrorButtonTitle
    )
    @Published var shouldCallDismiss: Bool = false

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return GOVUKButton.ButtonViewModel(
            localisedTitle: buttonTitle,
            action: {
                self.shouldCallDismiss = true
            }
        )
    }
}
