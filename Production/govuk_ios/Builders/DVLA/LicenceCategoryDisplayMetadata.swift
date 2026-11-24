/// UI presentation metadata for a driving licence category.
struct LicenceCategoryDisplayMetadata: Sendable {
    let displayName: String
    let group: LicenceCategoryGroup
    let image: ImageResource?

    /// Designated memberwise initializer.
    init(displayName: String, group: LicenceCategoryGroup, image: ImageResource?) {
        self.displayName = displayName
        self.group = group
        self.image = image
    }

    /// Creates display metadata for a known category.
    init(category: LicenceCategory) {
        self.init(
            displayName: category.displayName,
            group: category.group,
            image: category.image
        )
    }

    /// Creates display metadata for a raw category code, falling back gracefully if unrecognized.
    init(categoryCode: String) {
        if let category = LicenceCategory(code: categoryCode) {
            self.init(category: category)
        } else {
            self.init(
                displayName: categoryCode,
                group: .otherVehicles,
                image: nil
            )
        }
    }
}
