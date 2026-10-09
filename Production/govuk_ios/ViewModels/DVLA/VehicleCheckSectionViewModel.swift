import Foundation

struct VehicleCheckSectionViewModel {
    let action: (String) -> Void
    let buttonTitle: String = String(localized: .DVLA.vehicleCheckButtonTitle)
}
