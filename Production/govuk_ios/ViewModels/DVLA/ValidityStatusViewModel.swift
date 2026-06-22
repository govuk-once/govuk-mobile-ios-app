import Foundation
import UIKit
import GovKitUI

struct ValidityStatusViewModel {
    let title: String?
    let status: String
    let statusAccessibilityLabel: String?
    let iconName: String?
    let iconTintColour: UIColor?
    let footer: String?
    let buttonTitle: String?
    let buttonAction: (() -> Void)?

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
         status: String,
         statusAccessibilityLabel: String? = nil,
         iconName: String? = nil,
         iconTintColour: UIColor? = nil,
         footer: String? = nil,
         buttonTitle: String? = nil,
         buttonAction: (() -> Void)? = nil) {
        self.title = title
        self.status = status
        self.statusAccessibilityLabel = statusAccessibilityLabel
        self.iconName = iconName
        self.iconTintColour = iconTintColour
        self.footer = footer
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}
