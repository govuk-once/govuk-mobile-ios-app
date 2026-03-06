import Foundation
import GovKitUI

struct UnsetLocalWasteWidgetViewModel {
    let title: String = String.localWaste.localized(
        "localWasteTitle"
    )
    let widgetTitle: String = String.localWaste.localized(
        "unsetLocalWasteWidgetViewTitle"
    )
    let widgetDescription: String = String.localWaste.localized(
        "unsetLocalWasteWidgetViewDescription"
    )
    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        let buttonTitle = String.localWaste.localized(
            "unsetLocalWasteWidgetViewPrimaryButton"
        )
        return GOVUKButton.ButtonViewModel(
            localisedTitle: buttonTitle,
            action: {
                primaryAction()
            }
        )
    }

    let primaryAction: () -> Void
}
