import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct VehicleDetailViewModelTests {

    @Test
    func viewVehicleDetails_properties_mapCorrectly() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            vehicleId: 5,
            registrationNumber: "QW21 AB4",
            make: "Vauxhall"
        )
        let mockVehicleDetails = CustomerVehicleDetails.arrange(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: mockVehicle.vehicleId,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        #expect(details.registrationNumber == "QW21 AB4")
        #expect(details.make == "Vauxhall")

    }

    @Test
    func viewVehicleDetails_vehicleKeeperFullName_formattedCorrectly() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            keeperTitle: "MR",
            keeperFirstNames: "JOE",
            keeperLastName: "BLOGGS"
        )
        let mockVehicleDetails = CustomerVehicleDetails(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: mockVehicle.vehicleId,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        #expect(details.keeperFullName == "MR JOE BLOGGS")
    }

    @Test
    func viewVehicleDetails_vehicleKeeperAddress_formattedCorrectly() async {
        let expectedKeeperAddress = "1 Deansgate\nManchester\nM1 3EB"
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            keeperFullAddress: expectedKeeperAddress
        )
        let mockVehicleDetails = CustomerVehicleDetails(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: mockVehicle.vehicleId,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        #expect(details.keeperAddress == expectedKeeperAddress)
    }

    @Test
    func viewVehicleDetails_vehicleSpecViewModel_returnsPropertiesFormattedCorrectly() async {
        var mockVehicleSpecFormatter = MockVehicleSpecFormatter()
        mockVehicleSpecFormatter._stubbedFormattedYear = "2000"
        mockVehicleSpecFormatter._stubbedFormattedFuelTypeShort = "Petrol"
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(colour: "BLACK")
        let mockVehicleDetails = CustomerVehicleDetails(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: mockVehicle.vehicleId,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            specFormatter: mockVehicleSpecFormatter
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        #expect(details.vehicleSpecViewModel.colour == "Black")
        #expect(details.vehicleSpecViewModel.fuelTypeName == "Petrol")
        #expect(details.vehicleSpecViewModel.year == "2000")
    }

    @Test
    func viewVehicleDetails_taxStatusViewModel_hasCorrectTitle() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(colour: "BLACK")
        let mockVehicleDetails = CustomerVehicleDetails(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: 1,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        #expect(details.taxStatusViewModel.title == String(localized: .DVLA.taxStatusTitle))
    }

    @Test
    func viewVehicleDetails_motStatusViewModel_hasCorrectTitle() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(colour: "BLACK")
        let mockVehicleDetails = CustomerVehicleDetails(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: 1,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        #expect(details.motStatusViewModel.title == String(localized: .DVLA.motStatusTitle))
    }

    @Test
    func viewVehicleDetails_specificationSection_returnsExpectedRows() async {
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
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            make: "BMW"
        )
        let mockVehicleDetails = CustomerVehicleDetails(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let sut = VehicleDetailViewModel(
            vehicleId: mockVehicle.vehicleId,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            specFormatter: mockSpecFormatter
        )
        await sut.viewDidAppear()

        let details = viewVehicleDetails(sut.viewState)!
        let specificationSection = details.specificationSection
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

    private func viewVehicleDetails(
        _ viewState: VehicleDetailViewModel.ViewState
    ) -> ViewVehicleDetails? {
        switch viewState {
        case .loaded(let details):
            return details
        default:
            #expect(Bool(false), "Expected .loaded state")
            return nil
        }
    }
}
