import GovKit

extension AppErrorViewModel {
    static func dvlaAccountErrorWithAction(
        _ action: @escaping () -> Void
    ) -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.dvla.localized("dvlaAccountErrorBody"),
            buttonTitle: String.dvla.localized("dvlaAccountErrorButtonTitle"),
            buttonAccessibilityLabel: String.dvla.localized(
                "dvlaAccountErrorButtonTitle"
            ),
            isWebLink: false,
            action: action
        )
    }
}
