import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct VehicleSummaryViewModelTests {
    @Test
    func initWithVehicle_mapsPropertiesCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "FORD",
            model: "FOCUS"
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        #expect(sut.vehicleMake == "FORD")
        #expect(sut.vehicleModel == "FOCUS")
        #expect(sut.registrationNumber == "AB12 CDE")
    }

    @Test
    func vehicleModel_modelIsNil_returnsUnknown() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "FORD",
            model: nil
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        #expect(sut.vehicleModel == String.dvla.localized("unknown"))
    }

    @Test
    func registrationNumberAccessibilityLabel_formatsCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            registrationNumber: "AB12 CDE"
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        let format = String.dvla.localized("registrationNumberAccessibilityLabel")
        let expectedString = String.localizedStringWithFormat(format, "AB12 CDE")
        #expect(sut.registrationNumberAccessibilityLabel == expectedString)
    }

    @Test
    func taxStatusViewModel_taxedUntilDateIsValid_formatsStatusCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: Date(timeIntervalSince1970: 1779975444)
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        let expectedDate = Date(timeIntervalSince1970: 1779975444)
        let expectedDateString = DateFormatter.dvlaAccount.string(from: expectedDate)
        let format = String.dvla.localized("vehicleSummaryValidUntil")
        let expectedStatusString = String.localizedStringWithFormat(format, expectedDateString)
        #expect(sut.taxStatusViewModel.title == String.dvla.localized("taxStatusTitle"))
        #expect(sut.taxStatusViewModel.status == expectedStatusString)
    }

    @Test
    func taxStatusViewModel_taxedUntilDateIsNil_returnsUnknown() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: nil
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        #expect(sut.taxStatusViewModel.status == String.dvla.localized("unknown"))
    }

    @Test
    func motStatusViewModel_motExpiryDateIsValid_formatsStatusCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        let expectedDate = Date(timeIntervalSince1970: 1779975444)
        let expectedDateString = DateFormatter.dvlaAccount.string(from: expectedDate)
        let format = String.dvla.localized("vehicleSummaryValidUntil")
        let expectedStatusString = String.localizedStringWithFormat(format, expectedDateString)
        #expect(sut.motStatusViewModel.title == String.dvla.localized("motStatusTitle"))
        #expect(sut.motStatusViewModel.status == expectedStatusString)
    }

    @Test
    func motStatusViewModel_motExpiryDateIsNil_returnsUnknown() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            motExpiryDate: nil
        )
        let sut = VehicleSummaryViewModel(vehicle: mockVehicle)
        #expect(sut.motStatusViewModel.status == String.dvla.localized("unknown"))
    }
}
