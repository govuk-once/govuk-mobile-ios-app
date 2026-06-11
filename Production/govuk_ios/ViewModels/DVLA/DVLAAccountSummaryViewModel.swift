import GovKit
import SwiftUI

class DVLAAccountSummaryViewModel: ObservableObject {
    let vehiclesViewModel: VehiclesViewModel
    let licenceViewModel: DrivingLicenceViewModel

    init(vehiclesViewModel: VehiclesViewModel,
         licenceViewModel: DrivingLicenceViewModel) {
        self.vehiclesViewModel = vehiclesViewModel
        self.licenceViewModel = licenceViewModel
    }

    @MainActor
    func viewDidAppear() async {
        async let fetchVehicles: () = vehiclesViewModel.viewDidAppear()
        async let fetchLicence: () = licenceViewModel.viewDidAppear()

        _ = await (fetchVehicles, fetchLicence)
    }
}
