import SwiftUI
import GovKitUI

final class IconActionCardViewModel: ObservableObject {
    let iconName: String
    let title: String?
    let description: String?
    let action: () -> Void

    let contentPadding: CGFloat
    let iconBottomPadding: CGFloat

    init(
        iconName: String,
        title: String? = nil,
        description: String? = nil,
        action: @escaping () -> Void,
        contentPadding: CGFloat = 16,
        iconBottomPadding: CGFloat = 6
    ) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.action = action
        self.contentPadding = contentPadding
        self.iconBottomPadding = iconBottomPadding
    }

    var accessibilityLabel: String {
        [title, description]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
