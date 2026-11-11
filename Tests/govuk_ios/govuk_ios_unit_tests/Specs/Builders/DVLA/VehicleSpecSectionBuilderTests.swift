import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct VehicleSpecSectionBuilderTests {

    @Test
    func makeSection_forCustomerVehicleDetailsVehicle_returnsExpectedRows() {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange
        let mockVehicleSpecData = VehicleSpecData(vehicle: mockVehicle)
        let sut = VehicleSpecSectionBuilder(specFormatter: MockVehicleSpecFormatter())
        let result = sut.makeSection(for: mockVehicleSpecData)

        let expectedRowIds = [
            "vehicle.make.row",
            "vehicle.model.row",
            "vehicle.yearOfFirstRegistration.row",
            "vehicle.fuelType.row",
            "vehicle.colour.row",
            "vehicle.engineSize.row",
            "vehicle.emissions.row"
        ]
        #expect(result.rows.map(\.id) == expectedRowIds)
    }

    @Test
    func makeSection_forVehicleEnquiryResponseVehicle_returnsExpectedRows() {
        let mockVehicle = VehicleEnquiryResponse.Vehicle.arrange
        let mockVehicleSpecData = VehicleSpecData(vehicle: mockVehicle)
        let sut = VehicleSpecSectionBuilder(specFormatter: MockVehicleSpecFormatter())
        let result = sut.makeSection(for: mockVehicleSpecData)

        let expectedRowIds = [
            "vehicle.make.row",
            "vehicle.yearOfFirstRegistration.row",
            "vehicle.fuelType.row",
            "vehicle.colour.row",
            "vehicle.engineSize.row",
            "vehicle.emissions.row"
        ]
        #expect(result.rows.map(\.id) == expectedRowIds)
    }

    @Test
    func makeSection_returnsExpectedRowContent() {
        var mockSpecFormatter = MockVehicleSpecFormatter()
        mockSpecFormatter._stubbedFormattedModel = "X3"
        mockSpecFormatter._stubbedFormattedDateOfFirstRegistration = "January 2000"
        mockSpecFormatter._stubbedFormattedFuelTypeLong = "Petrol"
        mockSpecFormatter._stubbedFormattedColour = "Black"
        mockSpecFormatter._stubbedFormattedEmissions = "100"
        mockSpecFormatter._stubbedFormattedEngineSize = AccessibleString(
            "2.0L",
            accessibilityLabel: "2.0 litres"
        )
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            make: "BMW"
        )
        let mockVehicleSpecData = VehicleSpecData(vehicle: mockVehicle)

        let sut = VehicleSpecSectionBuilder(
            specFormatter: mockSpecFormatter
        )

        let specificationSection = sut.makeSection(for: mockVehicleSpecData)
        #expect(specificationSection.rows.count == 7)

        let makeRow = specificationSection.rows[0] as? InformationRow
        #expect(makeRow?.detail == "BMW")

        let modelRow = specificationSection.rows[1] as? InformationRow
        #expect(modelRow?.detail == "X3")

        let dateOfFirstRegistrationRow = specificationSection.rows[2] as? InformationRow
        #expect(dateOfFirstRegistrationRow?.detail == "January 2000")

        let fuelTypeRow = specificationSection.rows[3] as? InformationRow
        #expect(fuelTypeRow?.detail == "Petrol")

        let colourRow = specificationSection.rows[4] as? InformationRow
        #expect(colourRow?.detail == "Black")

        let engineSizeRow = specificationSection.rows[5] as? InformationRow
        #expect(engineSizeRow?.detail == "2.0L")

        let emissionsRow = specificationSection.rows[6] as? InformationRow
        #expect(emissionsRow?.detail == "100")
    }
}
