import SwiftUI
import GovKit
import GovKitUI

final class UnlinkAccountsErrorViewModel {
    private let unlinkErrorAction: () -> Void
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

    init(unlinkErrorAction: @escaping () -> Void) {
        self.unlinkErrorAction = unlinkErrorAction
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return GOVUKButton.ButtonViewModel(
            localisedTitle: buttonTitle,
            action: { [weak self] in
                self?.unlinkErrorAction()
            }
        )
    }
}
