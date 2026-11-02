import GovKit

extension AppErrorViewModel {
    static func travelAlertErrorWithoutAction() -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.travel.localized("countryListErrorDescription"),
            buttonTitle: nil,
            buttonAccessibilityLabel: nil,
            isWebLink: false,
            action: nil
        )
    }
}
