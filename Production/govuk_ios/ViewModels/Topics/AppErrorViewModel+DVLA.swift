import GovKit

extension AppErrorViewModel {
    static func dvlaAccountErrorWithAction(
        _ action: @escaping () -> Void
    ) -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.dvla.localized("accountLinkingErrorBody"),
            buttonTitle: String.dvla.localized("accountLinkingErrorButtonTitle"),
            buttonAccessibilityLabel: String.dvla.localized(
                "accountLinkingErrorButtonTitle"
            ),
            isWebLink: false,
            action: action
        )
    }
}
