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
}
