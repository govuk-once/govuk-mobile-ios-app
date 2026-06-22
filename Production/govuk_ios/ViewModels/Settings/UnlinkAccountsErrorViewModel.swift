import SwiftUI
import GovKit
import GovKitUI

final class UnlinkAccountsErrorViewModel {
    private let unlinkErrorAction: () -> Void
    let title = "There’s a problem"
    let description = "We could not remove your driver and vehicles account. Try again later."

    init(unlinkErrorAction: @escaping () -> Void) {
        self.unlinkErrorAction = unlinkErrorAction
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        let buttonTitle = "Go back to your accounts"
        return GOVUKButton.ButtonViewModel(
            localisedTitle: buttonTitle,
            action: { [weak self] in
                self?.unlinkErrorAction()
            }
        )
    }
}
