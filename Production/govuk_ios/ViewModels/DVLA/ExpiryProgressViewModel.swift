import Foundation

import SwiftUI
import GovKit

struct ExpiryProgressViewModel {
    let progress: CGFloat
    let daysLeft: String

    init(progress: CGFloat, daysLeft: Int) {
        self.progress = progress
        if daysLeft == 0 {
            self.daysLeft = String(localized: .DVLA.today)
        } else {
            self.daysLeft = String(localized: .DVLA.daysLeft(days: daysLeft))
        }
    }
}
