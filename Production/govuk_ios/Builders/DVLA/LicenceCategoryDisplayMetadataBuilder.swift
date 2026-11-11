import Foundation

struct LicenceCategoryDisplayMetadata {
    let displayName: String
    let group: LicenceCategoryGroup
    let image: ImageResource?
}

extension LicenceCategoryDisplayMetadata {
    init(categoryCode: String) {
        if let existing = LicenceCategoryDisplayMetadataBuilder.categoryRegistry[
            categoryCode.uppercased()
        ] {
            self = existing
        } else {
            self.init(displayName: categoryCode, group: .otherVehicles, image: nil)
        }
    }
}

/// Maps raw driving licence category codes to their display titles, groups, and associated asset icons.
enum LicenceCategoryDisplayMetadataBuilder {
    static let categoryRegistry: [String: LicenceCategoryDisplayMetadata] = [
        // MARK: - Mopeds
        "AM": .init(displayName: "AM", group: .mopeds, image: .drivingCategoryAM),
        "P": .init(displayName: "P", group: .mopeds, image: .drivingCategoryP),
        "Q": .init(displayName: "Q", group: .mopeds, image: .drivingCategoryQ),

        // MARK: - Motorcycles
        "A1": .init(displayName: "A1", group: .motorcycles, image: .drivingCategoryA1),
        "A2": .init(displayName: "A2", group: .motorcycles, image: .drivingCategoryA2),
        "A": .init(displayName: "A", group: .motorcycles, image: .drivingCategoryA),

        // MARK: - Light Vehicles & Quad Bikes
        "B1": .init(displayName: "B1", group: .lightVehicles, image: .drivingCategoryB1),

        // MARK: - Cars
        "B": .init(displayName: "B", group: .cars, image: .drivingCategoryB),
        "BE": .init(displayName: "BE", group: .cars, image: .drivingCategoryBE),

        // MARK: - Medium-Sized Vehicles
        "C1": .init(displayName: "C1", group: .mediumSizedVehicles, image: .drivingCategoryC1),
        "C1E": .init(displayName: "C1E", group: .mediumSizedVehicles, image: .drivingCategoryC1E),

        // MARK: - Large Vehicles
        "C": .init(displayName: "C", group: .largeVehicles, image: .drivingCategoryC),
        "CE": .init(displayName: "CE", group: .largeVehicles, image: .drivingCategoryCE),

        // MARK: - Minibuses
        "D1": .init(displayName: "D1", group: .minibuses, image: .drivingCategoryD1),
        "D1E": .init(displayName: "D1E", group: .minibuses, image: .drivingCategoryD1E),

        // MARK: - Buses & Coaches
        "D": .init(displayName: "D", group: .buses, image: .drivingCategoryD),
        "DE": .init(displayName: "DE", group: .buses, image: .drivingCategoryDE),

        // MARK: - Other Vehicles / Special Categories
        "F": .init(displayName: "f", group: .otherVehicles, image: nil),
        "G": .init(displayName: "G", group: .otherVehicles, image: nil),
        "H": .init(displayName: "H", group: .otherVehicles, image: nil),
        "K": .init(displayName: "k", group: .otherVehicles, image: nil),
        "L": .init(displayName: "l", group: .otherVehicles, image: nil),
        "M": .init(displayName: "M", group: .otherVehicles, image: nil),
        "N": .init(displayName: "n", group: .otherVehicles, image: nil)
    ]

    static func metadata(for categoryCode: String) -> LicenceCategoryDisplayMetadata {
        categoryRegistry[categoryCode.uppercased()] ??
            .init(displayName: categoryCode, group: .otherVehicles, image: nil)
    }
}
