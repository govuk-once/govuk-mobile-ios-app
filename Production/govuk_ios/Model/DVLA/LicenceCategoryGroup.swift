import Foundation

enum LicenceCategoryGroup: String {
    case mopeds
    case motorcycles
    case lightVehicles
    case cars
    case mediumSizedVehicles
    case largeVehicles
    case minibuses
    case buses
    case otherVehicles

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

    static func group(for code: String) -> LicenceCategoryGroup? {
        let uppercased = code.uppercased()
        switch uppercased {
        case "P", "AM", "Q":
            return .mopeds
        case "A", "A1", "A2":
            return .motorcycles
        case "B1":
            return .lightVehicles
        case "B", "BE":
            return .cars
        case "C1", "C1E":
            return .mediumSizedVehicles
        case "C", "CE":
            return .largeVehicles
        case "D1", "D1E":
            return .minibuses
        case "D", "DE":
            return .buses
        case "F", "G", "H", "K", "L", "M", "N":
            return .otherVehicles
        default:
            return nil
        }
    }
}
