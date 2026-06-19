import Foundation
import Testing

@testable import govuk_ios

struct FuelTypeTests {

    private let decoder = JSONDecoder()

    private func encoded(_ string: String) -> Data {
        "\"\(string)\"".data(using: .utf8)!
    }

    @Test(arguments: [
        ("PETROL", FuelType.petrol),
        ("DIESEL", FuelType.diesel),
        ("ELECTRICITY", FuelType.electricity),
        ("STEAM", FuelType.steam),
        ("GAS", FuelType.gas),
        ("PETROL/GAS", FuelType.petrolGas),
        ("GAS BI-FUEL", FuelType.gasBiFuel),
        ("HYBRID ELECTRIC", FuelType.hybridElectric),
        ("GAS DIESEL", FuelType.gasDiesel),
        ("FUEL CELLS", FuelType.fuelCells),
        ("ELECTRIC DIESEL", FuelType.electricDiesel),
        ("OTHER", FuelType.other)
    ])
    func decode_knownRawValue_returnsExpectedCase(rawValue: String, expected: FuelType) throws {
        let result = try decoder.decode(FuelType.self, from: encoded(rawValue))
        #expect(result == expected)
    }

    @Test
    func decode_unknownRawValue_fallsBackToOther() throws {
        let result = try decoder.decode(FuelType.self, from: encoded("ROCKET"))
        #expect(result == .unknown)
    }
}
