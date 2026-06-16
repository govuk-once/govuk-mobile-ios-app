import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

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
            vehicle: mockVehicle
        )
        #expect(sut.id == 5)
        #expect(sut.registrationNumber == "QW21 AB4")
        #expect(sut.vehicleMake == "Vauxhall")
    }

    @Test
    func vehicleSpecViewModel_colour_isCapitalized() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(colour: "BLACK")
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            vehicle: mockVehicle
        )
        #expect(sut.vehicleSpecViewModel.colour == "Black")
    }

    @Test
    func taxStatusViewModel_hasCorrectTitle() {
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            vehicle: .arrange
        )
        #expect(sut.taxStatusViewModel.title == String(localized: .DVLA.taxStatusTitle))
    }

    @Test
    func motStatusViewModel_hasCorrectTitle() {
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            vehicle: .arrange
        )
        #expect(sut.motStatusViewModel.title == String(localized: .DVLA.motStatusTitle))
    }

    @Test
    func specificationSection_returnsExpectedRows() {
        let mockVehicle = CustomerSummary.Vehicle.arrange
        let sut = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            vehicle: mockVehicle
        )
        let specificationSection = sut.specificationSection
        #expect(specificationSection.rows.count == 7)
    }

}
