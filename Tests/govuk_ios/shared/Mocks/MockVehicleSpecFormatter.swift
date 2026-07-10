import Foundation
@testable import govuk_ios

struct MockVehicleSpecFormatter: VehicleSpecFormatterInterface {
    var _stubbedFormattedYear: String?
    func formatYearOfFirstRegistration(from date: Date) -> String {
        _stubbedFormattedYear ?? "year"
    }
    var _stubbedFormattedModel: String?
    func formatModel(from model: String?) -> String {
        _stubbedFormattedModel ?? "model"
    }
    var _stubbedFormattedFuelTypeShort: String?
    func formatFuelTypeShort(from fuelType: FuelType) -> String {
        _stubbedFormattedFuelTypeShort ?? "fuel type"
    }
    var _stubbedFormattedFuelTypeLong: String?
    func formatFuelTypeLong(from fuelType: FuelType) -> String {
        _stubbedFormattedFuelTypeLong ?? "fuel type"
    }
    func getIconForFuelType(_ fuelType: FuelType) -> String {
        "icon"
    }
    var _stubbedFormattedColour: String?
    func formatColour(primary: String, secondary: String?) -> String {
        _stubbedFormattedColour ?? "colour"
    }
    var _stubbedFormattedEmissions: AccessibleString?
    func formatEmissions(from emissions: Int?) -> AccessibleString {
        _stubbedFormattedEmissions ??
        AccessibleString("display value", accessibilityLabel: "accessibility label")
    }
    var _stubbedFormattedEngineSize: AccessibleString?
    func formatEngineSize(from engineCapacity: Int?) -> AccessibleString {
        _stubbedFormattedEngineSize ??
        AccessibleString("display value", accessibilityLabel: "accessibility label")
    }
}
