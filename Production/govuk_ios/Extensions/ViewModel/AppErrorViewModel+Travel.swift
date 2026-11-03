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

    static func travelCountryListError(retryAction: @escaping () -> Void) -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.common.localized("genericErrorBody"),
            buttonTitle: String(localized: .Travel.countryListScreenErrorButtonTitle),
            buttonAccessibilityLabel: nil,
            isWebLink: false,
            action: retryAction
        )
    }
}
