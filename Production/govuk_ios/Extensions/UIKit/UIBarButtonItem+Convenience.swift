import Foundation
import UIKit
import GovKit

extension UIBarButtonItem {
    static func selectAll(action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        CenterAlignedBarButtonItem(
            title: String.recentActivity.localized("selectAllButtonTitle"),
            tint: UIColor.govUK.text.link,
            action: action
        )
    }

    static func deselectAll(action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        CenterAlignedBarButtonItem(
            title: String.recentActivity.localized("deselectAllButtonTitle"),
            tint: UIColor.govUK.text.link,
            action: action
        )
    }

    static func remove(action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        CenterAlignedBarButtonItem(
            title: String.recentActivity.localized("removeActivitiesButtonTitle"),
            tint: UIColor.govUK.text.buttonDestructive,
            action: action
        )
    }
}
