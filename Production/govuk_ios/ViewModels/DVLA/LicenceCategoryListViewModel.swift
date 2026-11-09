import Foundation
import GovKit

final class LicenceCategoryListViewModel: ObservableObject {
    private let didSelectAction: (Entitlement) -> Void
    private let dismissAction: () -> Void

    @Published var entitlements: [Entitlement]

    init(
        entitlements: [Entitlement],
        didSelectAction: @escaping (Entitlement) -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.entitlements = entitlements
        self.didSelectAction = didSelectAction
        self.dismissAction = dismissAction
    }

    func handleDidSelect(entitlement: Entitlement) {
        didSelectAction(entitlement)
    }

    func dismiss() {
        dismissAction()
    }
}
