import Foundation

/// High-level vehicle classifications used to group driving licence categories.
enum LicenceCategoryGroup: String, Sendable {
    case mopeds
    case motorcycles
    case lightVehicles
    case cars
    case mediumSizedVehicles
    case largeVehicles
    case minibuses
    case buses
    case otherVehicles

    /// The localized display title for the group.
    var title: String {
        switch self {
        case .mopeds: String(localized: .DVLA.categoryGroupMopeds)
        case .motorcycles: String(localized: .DVLA.categoryGroupMotorcycles)
        case .lightVehicles: String(localized: .DVLA.categoryGroupLightVehicles)
        case .cars: String(localized: .DVLA.categoryGroupCars)
        case .mediumSizedVehicles: String(localized: .DVLA.categoryGroupMediumSizedVehicles)
        case .largeVehicles: String(localized: .DVLA.categoryGroupLargeVehicles)
        case .minibuses: String(localized: .DVLA.categoryGroupMinibuses)
        case .buses: String(localized: .DVLA.categoryGroupBuses)
        case .otherVehicles: String(localized: .DVLA.categoryGroupOtherVehicles)
        }
    }
}

/// Known DVLA driving licence category codes acting as the single source of truth.
enum LicenceCategory: String, Sendable, CaseIterable {
    // swiftlint:disable identifier_name
    case am = "AM", p = "P", q = "Q"
    case a1 = "A1", a2 = "A2", a = "A"
    case b1 = "B1"
    case b = "B", be = "BE"
    case c1 = "C1", c1e = "C1E"
    case c = "C", ce = "CE"
    case d1 = "D1", d1e = "D1E"
    case d = "D", de = "DE"
    case f = "F", g = "G", h = "H", k = "K", l = "L", m = "M", n = "N"
    // swiftlint:enable identifier_name

    /// Creates a category from a case-insensitive category code.
    init?(code: String) {
        self.init(rawValue: code.uppercased())
    }

    /// The vehicle group this category belongs to.
    var group: LicenceCategoryGroup {
        switch self {
        case .am, .p, .q: .mopeds
        case .a1, .a2, .a: .motorcycles
        case .b1: .lightVehicles
        case .b, .be: .cars
        case .c1, .c1e: .mediumSizedVehicles
        case .c, .ce: .largeVehicles
        case .d1, .d1e: .minibuses
        case .d, .de: .buses
        case .f, .g, .h, .k, .l, .m, .n: .otherVehicles
        }
    }

    /// The official display name for the category.
    var displayName: String {
        switch self {
        case .f: "f"
        case .k: "k"
        case .l: "l"
        default: rawValue
        }
    }

    /// The asset image resource associated with the category, if any.
    var image: ImageResource? {
        switch self {
        case .am: .drivingCategoryAM
        case .p: .drivingCategoryP
        case .q: .drivingCategoryQ
        case .a1: .drivingCategoryA1
        case .a2: .drivingCategoryA2
        case .a: .drivingCategoryA
        case .b1: .drivingCategoryB1
        case .b: .drivingCategoryB
        case .be: .drivingCategoryBE
        case .c1: .drivingCategoryC1
        case .c1e: .drivingCategoryC1E
        case .c: .drivingCategoryC
        case .ce: .drivingCategoryCE
        case .d1: .drivingCategoryD1
        case .d1e: .drivingCategoryD1E
        case .d: .drivingCategoryD
        case .de: .drivingCategoryDE
        case .f, .g, .h, .k, .l, .m, .n: nil
        }
    }
}
