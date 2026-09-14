import Foundation
import UIKit
import GovKitUI

protocol ValidityStatus {}

///
/// Represents information to be displayed in a status section of the UI.
/// This will replace the use of `formattedStatus` which is being used inconsistently.
///
struct StatusInformation: Equatable {
    let title: String   // formattedStatus
    let accessibilityLabel: String?
    let linkAction: (() -> Void)?

    var accessibilityLabelOrTitle: String {
        accessibilityLabel ?? title
    }

    static func == (lhs: StatusInformation, rhs: StatusInformation) -> Bool {
            lhs.title == rhs.title &&
            lhs.accessibilityLabel == rhs.accessibilityLabel &&
            ((lhs.linkAction == nil) == (rhs.linkAction == nil))
    }
}

struct ValidityStatusViewModel {
    let title: String?
    let formattedStatus: String
    let status: ValidityStatus?
    let statusAccessibilityLabel: String?
    let statusLinkAction: (() -> Void)?
    let iconName: String?
    let iconTintColour: UIColor?
    let progressViewModel: ExpiryProgressViewModel?
    let footer: String?
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    let buttonConfiguration: GOVUKButton.ButtonConfiguration?

    var buttonViewModel: GOVUKButton.ButtonViewModel? {
        guard let buttonTitle = buttonTitle,
              let buttonAction = buttonAction else {
            return nil
        }
        return .init(
            localisedTitle: buttonTitle,
            action: buttonAction
        )
    }

    init(title: String? = nil,
         formattedStatus: String,
         status: ValidityStatus? = nil,
         statusAccessibilityLabel: String? = nil,
         statusLinkAction: (() -> Void)? = nil,
         iconName: String? = nil,
         iconTintColour: UIColor? = nil,
         progressViewModel: ExpiryProgressViewModel? = nil,
         footer: String? = nil,
         buttonTitle: String? = nil,
         buttonAction: (() -> Void)? = nil,
         buttonConfiguration: GOVUKButton.ButtonConfiguration? = nil) {
        self.title = title
        self.formattedStatus = formattedStatus
        self.statusAccessibilityLabel = statusAccessibilityLabel
        self.iconName = iconName
        self.iconTintColour = iconTintColour
        self.progressViewModel = progressViewModel
        self.footer = footer
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.buttonConfiguration = buttonConfiguration
        self.status = status
        self.statusLinkAction = statusLinkAction
    }
}
