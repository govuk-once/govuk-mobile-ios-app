import Foundation
import UIKit
import GovKitUI

struct ValidityStatusViewModel {
    let title: String?
    let formattedStatus: String
    let status: Codable?
    let statusAccessibilityLabel: String?
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
         status: Codable? = nil,
         statusAccessibilityLabel: String? = nil,
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
    }
}
