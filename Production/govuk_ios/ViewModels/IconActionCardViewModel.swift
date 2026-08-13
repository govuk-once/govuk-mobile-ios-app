import SwiftUI
import GovKitUI

final class IconActionCardViewModel: ObservableObject {
    let iconName: String
    let title: String?
    let description: String?
    let action: () -> Void

    init(
        iconName: String,
        title: String? = nil,
        description: String? = nil,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.action = action
    }

    var accessibilityLabel: String {
        [title, description]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
