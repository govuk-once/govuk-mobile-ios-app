import Foundation

import SwiftUI
import GovKit

struct ExpiryProgressViewModel {
    let progress: CGFloat
    let footer: String

    init(
        progress: CGFloat,
        daysLeft: Int,
        footer: String? = nil
    ) {
        self.progress = progress
        if let footer {
            self.footer = footer
        } else if daysLeft == 0 {
            self.footer = String(localized: .DVLA.today)
        } else {
            self.footer = String(localized: .DVLA.daysLeft(days: daysLeft))
        }
    }
}
