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

    static func travelGenericError(retryAction: @escaping () -> Void) -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.travel.localized("travelGenericErrorMessage"),
            buttonTitle: String.travel.localized("travelGenericErrorButtonTitle"),
            buttonAccessibilityLabel: nil,
            isWebLink: false,
            action: retryAction
        )
    }
}
