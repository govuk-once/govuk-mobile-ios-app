//


import Foundation
import GovKitUI
import GovKit

class FollowCountryViewModel {
    let dismissAction: () -> Void

    init(
        dismissAction: @escaping () -> Void
    ) {
        self.dismissAction = dismissAction
    }
}
