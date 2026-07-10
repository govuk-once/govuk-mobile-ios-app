import Foundation

protocol VehicleSpecFormatterInterface {
    func formatYearOfFirstRegistration(from date: Date) -> String
    func formatModel(from model: String?) -> String
    func formatFuelTypeShort(from fuelType: FuelType) -> String
    func formatFuelTypeLong(from fuelType: FuelType) -> String
    func getIconForFuelType(_ fuelType: FuelType) -> String
    func formatColour(primary: String, secondary: String?) -> String
    func formatEmissions(from emissions: Int?) -> AccessibleString
    func formatEngineSize(from engineCapacity: Int?) -> AccessibleString
}

struct VehicleSpecFormatter: VehicleSpecFormatterInterface {
    func formatYearOfFirstRegistration(from date: Date) -> String {
        return date.formatted(.dateTime.year())
    }

    func formatModel(from model: String?) -> String {
        return model ?? String(localized: .DVLA.unknown)
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

    func formatEmissions(from emissions: Int?) -> AccessibleString {
        guard let co2Emissions = emissions else {
            return AccessibleString(String(localized: .DVLA.unknown))
        }
        let displayText = String(
            localized: .DVLA.emissionsInGramsPerKm(
                emissions: co2Emissions
            )
        )
        let accessibilityLabel = String(
            localized: .DVLA.emissionsInGramsPerKmAccessibilityLabel(
                emissions: co2Emissions
            )
        )
        return AccessibleString(displayText, accessibilityLabel: accessibilityLabel)
    }

    func formatEngineSize(from engineCapacity: Int?) -> AccessibleString {
        guard let engineCapacity = engineCapacity else {
            return AccessibleString(String(localized: .DVLA.unknown))
        }
        if engineCapacity < 1000 {
            let engineCapacityInCc = String(
                localized: .DVLA.engineCapacityCc(capacity: engineCapacity)
            )
            return AccessibleString(engineCapacityInCc)
        }
        let decimalValue = Double(engineCapacity) / 1000.0
        let displayText = String(localized: .DVLA.engineCapacityLitres(capacity: decimalValue))
        let accessibilityLabel: String
        if engineCapacity == 1000 {
            accessibilityLabel = String(
                localized: .DVLA.engineCapacityLitreAccessibilityLabel(capacity: decimalValue)
            )
        } else {
            accessibilityLabel = String(
                localized: .DVLA.engineCapacityLitresAccessibilityLabel(capacity: decimalValue)
            )
        }
        return AccessibleString(displayText, accessibilityLabel: accessibilityLabel)
    }
}
