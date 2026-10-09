import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct DVLAAccountSummaryViewModelTests {
    @Test
    func viewDidAppear_callsVehiclesViewModelViewDidAppear() async {
        let mockVehiclesViewModel = MockVehiclesViewModel(viewState: .loading)
        let mockLicenceViewModel = MockDrivingLicenceViewModel(viewState: .loading)
        let mockVehicleCheckSectionViewModel = VehicleCheckSectionViewModel(action: { _ in })

        let sut = DVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel,
            vehicleCheckSectionViewModel: mockVehicleCheckSectionViewModel
        )
        await sut.viewDidAppear()
        #expect(mockLicenceViewModel._viewDidAppearCalled == true)
        #expect(mockVehiclesViewModel._viewDidAppearCalled == true)
    }
}
