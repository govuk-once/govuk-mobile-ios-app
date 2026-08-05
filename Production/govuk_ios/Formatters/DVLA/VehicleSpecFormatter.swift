import Foundation

protocol VehicleSpecFormatterInterface {
    func formatYearOfFirstRegistration(from date: Date) -> String
    func formatDateOfFirstRegistration(_ date: Date) -> String
    func formatModel(from model: String?) -> String
    func formatFuelTypeShort(from fuelType: FuelType) -> String
    func formatFuelTypeLong(from fuelType: FuelType) -> String
    func getIconForFuelType(_ fuelType: FuelType) -> String
    func formatColour(primary: String, secondary: String?) -> String
    func formatEmissions(from emissions: Int?) -> String
    func formatEngineSize(from engineCapacity: Int?) -> AccessibleString
}

struct VehicleSpecFormatter: VehicleSpecFormatterInterface {
    func formatYearOfFirstRegistration(from date: Date) -> String {
        return date.formatted(.dateTime.year())
    }

    func formatDateOfFirstRegistration(_ date: Date) -> String {
        return date.formatted(.dateTime.month(.wide).year())
    }

    func formatModel(from model: String?) -> String {
        return model ?? ""
    }

    func formatFuelTypeShort(from fuelType: FuelType) -> String {
        switch fuelType {
        case .petrolGas, .gasBiFuel, .gasDiesel:
            String(localized: .DVLA.biFuel)
        case .hybridElectric, .electricDiesel:
            String(localized: .DVLA.hybrid)
        case .fuelCells:
            String(localized: .DVLA.hydrogen)
        default:
            fuelType.rawValue.capitalized
        }
    }

    func formatFuelTypeLong(from fuelType: FuelType) -> String {
        switch fuelType {
        case .petrolGas:
            String(localized: .DVLA.petrolAndGas)
        case .gasBiFuel:
            String(localized: .DVLA.gasBiFuel)
        case .hybridElectric:
            String(localized: .DVLA.hybridElectric)
        case .gasDiesel:
            String(localized: .DVLA.gasAndDiesel)
        case .fuelCells:
            String(localized: .DVLA.hydrogen)
        case .electricDiesel:
            String(localized: .DVLA.electricDiesel)
        default:
            fuelType.rawValue.capitalized
        }
    }

    func getIconForFuelType(_ fuelType: FuelType) -> String {
        switch fuelType {
        case .diesel, .petrol:
             "fuelpump.fill"
        case .hybridElectric, .electricDiesel:
            "leaf.fill"
        case .electricity:
            "bolt.batteryblock.fill"
        case .gas:
            "aqi.medium"
        case .steam:
            "humidity.fill"
        default:
            "fuelpump.fill"
        }
    }

    func formatColour(primary: String, secondary: String?) -> String {
        guard let secondary = secondary else {
            return primary.capitalized
        }
        return String(
            localized: .DVLA.primaryAndSecondaryColour(
                primary: primary.capitalized,
                secondary: secondary.lowercased()
            )
        )
    }

    func formatEmissions(from emissions: Int?) -> String {
        guard let co2Emissions = emissions else {
            return String(localized: .DVLA.unknown)
        }
        return String(co2Emissions)
    }

    func formatEngineSize(from engineCapacity: Int?) -> AccessibleString {
        guard let engineCapacity = engineCapacity else {
            return AccessibleString(String(localized: .DVLA.unknown))
        }
        let engineCapacityInCc = String(
            localized: .DVLA.engineCapacityCc(capacity: String(engineCapacity))
        )
        let accessibleEngineCapacityInCc = String(
            localized: .DVLA.engineCapacityCcAccessibilityLabel(capacity: engineCapacity)
        )
        return AccessibleString(
            engineCapacityInCc,
            accessibilityLabel: accessibleEngineCapacityInCc
        )
    }
}
