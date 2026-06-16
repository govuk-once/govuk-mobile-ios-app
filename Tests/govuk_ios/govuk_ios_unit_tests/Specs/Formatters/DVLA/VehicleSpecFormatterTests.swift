import Foundation
import Testing

@testable import govuk_ios

@Suite
struct VehicleSpecFormatterTests {
    let sut = VehicleSpecFormatter()

    @Test
    func formatYearOfFirstRegistration_returnsExpectedResult() {
        let result = sut.formatYearOfFirstRegistration(from: .arrange("01/03/1999"))
        #expect(result == "1999")
    }

    @Test
    func formatModel_modelIsNotNil_returnsModel() {
        let result = sut.formatModel(from: "GOLF")
        #expect(result == "GOLF")
    }

    @Test
    func formatModel_modelIsNil_returnsUnknown() {
        let result = sut.formatModel(from: nil)
        #expect(result == String(localized: .DVLA.unknown))
    }

    @Test(arguments: zip(
        [
            FuelType.petrol,
            .diesel,
            .electricity,
            .steam,
            .gas,
            .petrolGas,
            .gasBiFuel,
            .hybridElectric,
            .gasDiesel,
            .fuelCells,
            .electricDiesel,
            .other
        ],
        [
            FuelType.petrol.rawValue.capitalized,
            FuelType.diesel.rawValue.capitalized,
            FuelType.electricity.rawValue.capitalized,
            FuelType.steam.rawValue.capitalized,
            FuelType.gas.rawValue.capitalized,
            String(localized: .DVLA.biFuel),
            String(localized: .DVLA.biFuel),
            String(localized: .DVLA.hybrid),
            String(localized: .DVLA.biFuel),
            String(localized: .DVLA.hydrogen),
            String(localized: .DVLA.hybrid),
            FuelType.other.rawValue.capitalized
        ]
    ))
    func formatFuelTypeShort_returnsExpectedResult(_ fuelType: FuelType, expectedString: String) {
        let result = sut.formatFuelTypeShort(from: fuelType)
        #expect(result == expectedString)
    }

    @Test(arguments: zip(
        [
            FuelType.petrol,
            .diesel,
            .electricity,
            .steam,
            .gas,
            .petrolGas,
            .gasBiFuel,
            .hybridElectric,
            .gasDiesel,
            .fuelCells,
            .electricDiesel,
            .other
        ],
        [
            FuelType.petrol.rawValue.capitalized,
            FuelType.diesel.rawValue.capitalized,
            FuelType.electricity.rawValue.capitalized,
            FuelType.steam.rawValue.capitalized,
            FuelType.gas.rawValue.capitalized,
            String(localized: .DVLA.petrolAndGas),
            String(localized: .DVLA.gasBiFuel),
            String(localized: .DVLA.hybridElectric),
            String(localized: .DVLA.gasAndDiesel),
            String(localized: .DVLA.hydrogen),
            String(localized: .DVLA.electricDiesel),
            FuelType.other.rawValue.capitalized
        ]
    ))
          func formatFuelTypeLong_returnsExpectedResult(_ fuelType: FuelType, expectedString: String) {
              let result = sut.formatFuelTypeLong(from: fuelType)
              #expect(result == expectedString)
    }

    @Test(arguments: zip(
        [
            FuelType.petrol,
            .diesel,
            .electricity,
            .steam,
            .gas,
            .petrolGas,
            .gasBiFuel,
            .hybridElectric,
            .gasDiesel,
            .fuelCells,
            .electricDiesel,
            .other
        ],
        [
            "fuelpump.fill",
            "fuelpump.fill",
            "bolt.batteryblock.fill",
            "humidity.fill",
            "aqi.medium",
            "fuelpump.fill",
            "fuelpump.fill",
            "leaf.fill",
            "fuelpump.fill",
            "fuelpump.fill",
            "leaf.fill",
            "fuelpump.fill"
        ]
    ))
    func getIconForFuelType_returnsExpectedResult(_ fuelType: FuelType, expectedIconName: String) {
        let result = sut.getIconForFuelType(fuelType)
        #expect(result == expectedIconName)
    }

    @Test
    func formatColour_secondaryColourIsNil_returnsPrimaryColourOnly() {
        let result = sut.formatColour(primary: "blue", secondary: nil)
        #expect(result == "Blue")
    }

    @Test
    func formatColour_secondaryColourIsNotNil_returnsBothColours() {
        let result = sut.formatColour(primary: "blue", secondary: "white")
        #expect(result == "Blue and white")
    }

    @Test
    func formatEmissions_emissionsIsNil_returnsUnknown() {
        let result = sut.formatEmissions(from: nil)
        #expect(result == String(localized: .DVLA.unknown))
    }

    @Test
    func formatEmissions_valideCo2Emissions_returnsExpectedResult() {
        let result = sut.formatEmissions(from: .init(co2: 100))
        let expectedString = String(
            localized: .DVLA.emissionsInGramsPerKm(
                emissions: 100
            )
        )
        #expect(result == expectedString)
    }

    @Test
    func formatEngineSize_engineCapacityIsNil_returnsUnknown() {
        let result = sut.formatEngineSize(from: nil)
        #expect(result == String(localized: .DVLA.unknown))
    }

    @Test
    func formatEngineSize_engineCapacityLessThan1000_returnsExpectedResult() {
        let result = sut.formatEngineSize(from: 750)
        let expectedString = String(localized: .DVLA.engineCapacityCc(capacity: 750))
        #expect(result == expectedString)
    }

    @Test
    func formatEngineSize_engineCapacityGreaterThanOrEquals1000_returnsExpectedResult() {
        let result = sut.formatEngineSize(from: 2495)
        let expectedString = String(localized: .DVLA.engineCapacityLitres(capacity: 2.5))
        #expect(result == expectedString)
    }
}
