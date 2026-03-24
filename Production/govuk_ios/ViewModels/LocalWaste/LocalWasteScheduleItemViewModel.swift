struct LocalWasteScheduleItemViewModel: Identifiable, Hashable {
    let color: LocalWasteBinColor?
    let title: String
    let description: String?
    let accessibilityLabel: String
    let id: String

    init(color: LocalWasteBinColor?,
         title: String,
         description: String?) {
        self.color = color
        self.title = title
        self.description = description
        self.id = "\(color?.rawValue ?? "")!\(title)!\(description ?? "")"

        var accessibilityLabel = title
        if let colorAccessibility = color?.accessibilityLabel {
            accessibilityLabel += ", \(colorAccessibility)"
        }
        if let description {
            accessibilityLabel += ", \(description)"
        }
        self.accessibilityLabel = accessibilityLabel
    }
}

struct LocalWasteScheduleGroupViewModel: Identifiable, Hashable {
    let dateDisplay: String
    let items: [LocalWasteScheduleItemViewModel]

    var id: String {
        dateDisplay
    }
}
