import Foundation

class AlertDetails {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryButtonAction: (() -> Void)?
    let secondaryButtonTitle: String?
    let secondaryButtonAction: (() -> Void)?

    init(title: String,
         message: String,
         primaryButtonTitle: String,
         primaryButtonAction: (() -> Void)? = nil,
         secondaryButtonTitle: String? = nil,
         secondaryButtonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
    }
}
