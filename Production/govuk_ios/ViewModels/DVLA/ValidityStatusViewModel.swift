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
    let title: String
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

    init(title: String, accessibilityLabel: String?, linkAction: (() -> Void)?) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.linkAction = linkAction
    }

    init(_ title: String) {
        self.title = title
        self.accessibilityLabel = nil
        self.linkAction = nil
    }

    init(_ title: String, linkAction: (() -> Void)?) {
        self.title = title
        self.accessibilityLabel = nil
        self.linkAction = linkAction
    }

    init(_ title: String, accessibilityLabel: String) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.linkAction = nil
    }
}
