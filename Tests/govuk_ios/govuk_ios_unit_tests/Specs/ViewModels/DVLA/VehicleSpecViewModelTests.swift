import Foundation
import Testing

@testable import govuk_ios

@Suite
struct VehicleSpecViewModelTests {
    @Test
    func yearAccessibilityLabel_returnsExpectedResult() {
        let sut = VehicleSpecViewModel(
            colour: "Green",
            fuelTypeIcon: "IconName",
            fuelTypeName: "Petrol",
            year: "2012"
        )
        let expectedString = String(localized: .DVLA.firstRegisteredAccessibilityLabel(year: "2012"))
        #expect(sut.yearAccessibilityLabel == expectedString)
    }

    @Test
    func fuelTypeAccessibilityLabel_returnsExpectedResult() {
        let sut = VehicleSpecViewModel(
            colour: "Green",
            fuelTypeIcon: "IconName",
            fuelTypeName: "Petrol",
            year: "2012"
        )
        let expectedString = String(localized: .DVLA.fuelTypeAccessibilityLabel(fuelType: "Petrol"))
        #expect(sut.fuelTypeAccessibilityLabel == expectedString)
    }

    @Test
    func colourAccessibilityLabel_returnsExpectedResult() {
        let sut = VehicleSpecViewModel(
            colour: "Green",
            fuelTypeIcon: "IconName",
            fuelTypeName: "Petrol",
            year: "2012"
        )
        let expectedString = String(localized: .DVLA.colourAccessibilityLabel(colour: "Green"))
        #expect(sut.colourAccessibilityLabel == expectedString)
    }
}
