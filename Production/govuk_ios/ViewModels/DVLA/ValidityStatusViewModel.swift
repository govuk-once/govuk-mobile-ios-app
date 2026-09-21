import Foundation
import UIKit
import GovKitUI

protocol ValidityStatus {}

struct ValidityStatusViewModel {
    let title: String?
    let status: ValidityStatus?

    let statusInformation: StatusInformation?

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
         status: ValidityStatus? = nil,
         statusInformation: StatusInformation?,
         iconName: String? = nil,
         iconTintColour: UIColor? = nil,
         progressViewModel: ExpiryProgressViewModel? = nil,
         footer: String? = nil,
         buttonTitle: String? = nil,
         buttonAction: (() -> Void)? = nil,
         buttonConfiguration: GOVUKButton.ButtonConfiguration? = nil) {
        self.title = title
        self.iconName = iconName
        self.iconTintColour = iconTintColour
        self.progressViewModel = progressViewModel
        self.footer = footer
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.buttonConfiguration = buttonConfiguration
        self.status = status
        self.statusInformation = statusInformation
    }
}

///
/// Represents information to be displayed in a status section of the UI.
///
struct StatusInformation: Equatable {
    private let title: AccessibleString
    let linkAction: (() -> Void)?

    var displayValue: String { title.displayValue }
    var accessibilityLabel: String { title.accessibilityLabel }

    static func == (lhs: StatusInformation, rhs: StatusInformation) -> Bool {
            lhs.title == rhs.title &&
            ((lhs.linkAction == nil) == (rhs.linkAction == nil))
    }

    init(_ title: String, accessibilityLabel: String? = nil, linkAction: (() -> Void)? = nil) {
        self.title = AccessibleString(title, accessibilityLabel: accessibilityLabel)
        self.linkAction = linkAction
    }
}
