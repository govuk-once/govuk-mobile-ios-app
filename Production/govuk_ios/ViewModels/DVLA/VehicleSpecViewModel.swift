import Foundation

struct VehicleSpecViewModel {
    let colour: String
    let fuelTypeIcon: String
    let fuelTypeName: String
    let year: String
    let yearAccessibilityLabel: String
    let fuelTypeAccessibilityLabel: String
    let colourAccessibilityLabel: String

    init(colour: String,
         fuelTypeIcon: String,
         fuelTypeName: String,
         year: String) {
        self.colour = colour
        self.fuelTypeIcon = fuelTypeIcon
        self.fuelTypeName = fuelTypeName
        self.year = year
        self.yearAccessibilityLabel = String(
            localized: .DVLA.firstRegisteredAccessibilityLabel(year: year)
        )
        self.fuelTypeAccessibilityLabel = String(
            localized: .DVLA.fuelTypeAccessibilityLabel(fuelType: fuelTypeName)
        )
        self.colourAccessibilityLabel = String(
            localized: .DVLA.colourAccessibilityLabel(colour: colour)
        )
    }
}
