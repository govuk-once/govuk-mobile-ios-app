import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@MainActor
@Suite
struct VehicleDetailViewModelTests {

    @Test
    func vehicleProperties_mapCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            vehicleId: 5,
            registrationNumber: "QW21 AB4",
            make: "Vauxhall"
        )
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        #expect(sut.id == 5)
        #expect(sut.registrationNumber == "QW21 AB4")
        #expect(sut.vehicleMake == "Vauxhall")
    }

    // update this when new vehicle endpoint is provided with new full name field
    @Test
    func vehicleKeeperFullName_formattedCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            keeper: .init(
                title: "MR",
                firstNames: "JOE",
                lastName: "BLOGGS",
                address: nil
            )
        )
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        #expect(sut.keeperFullName == "MR JOE BLOGGS")
    }

    // update this when new vehicle endpoint is provided with new address field
    @Test
    func vehicleKeeperAddress_formattedCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            keeper: .init(
                title: "MR",
                firstNames: "JOE",
                lastName: "BLOGGS",
                address: .init(
                    unstructuredAddress: .init(
                        line1: "1 Deansgate",
                        line2: nil,
                        line3: nil,
                        line4: nil,
                        line5: "Manchester",
                        postcode: "M1 3EB")
                )
            )
        )
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        let expectedAddress = [
            "1 Deansgate",
            "Manchester",
            "M1 3EB"
        ]
        #expect(sut.keeperAddress == expectedAddress)
    }

    @Test
    func vehicleSpecViewModel_returnsPropertiesFormattedCorrectly() {
        var mockVehicleSpecFormatter = MockVehicleSpecFormatter()
        mockVehicleSpecFormatter._stubbedFormattedYear = "2000"
        mockVehicleSpecFormatter._stubbedFormattedFuelTypeShort = "Petrol"
        let mockVehicle = CustomerSummary.Vehicle.arrange(colour: "BLACK")
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in },
            specFormatter: mockVehicleSpecFormatter
        )
        #expect(sut.vehicleSpecViewModel.colour == "Black")
        #expect(sut.vehicleSpecViewModel.fuelTypeName == "Petrol")
        #expect(sut.vehicleSpecViewModel.year == "2000")
    }

    @Test
    func taxStatusViewModel_hasCorrectTitle() {
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: .arrange,
            openURLAction: { _ in }
        )
        #expect(sut.taxStatusViewModel.title == String(localized: .DVLA.taxStatusTitle))
    }

    @Test
    func motStatusViewModel_hasCorrectTitle() {
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: .arrange,
            openURLAction: { _ in }
        )
        #expect(sut.motStatusViewModel.title == String(localized: .DVLA.motStatusTitle))
    }

    @Test
    func specificationSection_returnsExpectedRows() {
        var mockSpecFormatter = MockVehicleSpecFormatter()
        mockSpecFormatter._stubbedFormattedModel = "X3"
        mockSpecFormatter._stubbedFormattedYear = "2000"
        mockSpecFormatter._stubbedFormattedFuelTypeLong = "Petrol"
        mockSpecFormatter._stubbedFormattedColour = "Black"
        mockSpecFormatter._stubbedFormattedEmissions = AccessibleString(
            "100g/km",
            accessibilityLabel: "100 grams per kilometer"
        )
        mockSpecFormatter._stubbedFormattedEngineSize = AccessibleString(
            "2.0L",
            accessibilityLabel: "2.0 litres"
        )

        let mockVehicle = CustomerSummary.Vehicle.arrange(
            make: "BMW"
        )
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in },
            specFormatter: mockSpecFormatter
        )
        let specificationSection = sut.specificationSection
        #expect(specificationSection.rows.count == 7)

        let makeRow = specificationSection.rows[0] as? InformationRow
        #expect(makeRow?.detail == "BMW")

        let modelRow = specificationSection.rows[1] as? InformationRow
        #expect(modelRow?.detail == "X3")

        let yearOfFirstRegistrationRow = specificationSection.rows[2] as? InformationRow
        #expect(yearOfFirstRegistrationRow?.detail == "2000")

        let fuelTypeRow = specificationSection.rows[3] as? InformationRow
        #expect(fuelTypeRow?.detail == "Petrol")

        let colourRow = specificationSection.rows[4] as? InformationRow
        #expect(colourRow?.detail == "Black")

        let engineSizeRow = specificationSection.rows[5] as? InformationRow
        #expect(engineSizeRow?.detail == "2.0L")

        let emissionsRow = specificationSection.rows[6] as? InformationRow
        #expect(emissionsRow?.detail == "100g/km")
    }

}
