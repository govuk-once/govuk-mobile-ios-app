import GovKit

extension AppErrorViewModel {
    static func serviceAccountErrorWithAction(
        _ action: @escaping () -> Void
    ) -> AppErrorViewModel {
        AppErrorViewModel(
            title: String.common.localized("genericErrorTitle"),
            body: String.serviceAccount.localized("accountLinkingErrorBody"),
            buttonTitle: String.serviceAccount.localized("accountLinkingErrorButtonTitle"),
            buttonAccessibilityLabel: String.serviceAccount.localized(
                "accountLinkingErrorButtonTitle"
            ),
            isWebLink: false,
            action: action
        )
    }
}
