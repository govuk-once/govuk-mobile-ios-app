import Foundation

struct DvlaMenuItemViewModel: Identifiable {
    let id = UUID().uuidString
    let title: String
    let accessibilityLabel: String?
    let openURLAction: (String) -> Void
}
