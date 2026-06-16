import Foundation

struct VehicleSpecFormatter {
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
    func formatEmissions(from emissions: ExhaustEmissions?) -> String {
        guard let co2Emissions = emissions?.co2 else {
            return String(localized: .DVLA.unknown)
        }
        return String(
            localized: .DVLA.emissionsInGramsPerKm(
                emissions: co2Emissions
            )
        )
    }
    func formatEngineSize(from engineCapacity: Int?) -> String {
        guard let engineCapacity = engineCapacity else {
            return String(localized: .DVLA.unknown)
        }
        if engineCapacity < 1000 {
            return String(localized: .DVLA.engineCapacityCc(capacity: engineCapacity))
        }
        let decimalValue = Double(engineCapacity) / 1000.0
        return String(localized: .DVLA.engineCapacityLitres(capacity: decimalValue))
    }
}
