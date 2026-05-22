import GovKit

extension AppErrorViewModel {
    static func serviceAccountUnlinkingErrorWithAction(
        _ action: @escaping () -> Void
    ) -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.serviceAccount.localized("accountUnlinkingErrorBody"),
            buttonTitle: String.dvla.localized("dvlaAccountErrorButtonTitle"),
            buttonAccessibilityLabel: String.serviceAccount.localized(
                "accountLinkingErrorButtonTitle"
            ),
            isWebLink: false,
            action: action
        )
    }
}
