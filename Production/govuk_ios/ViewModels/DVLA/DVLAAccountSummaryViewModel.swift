import GovKit
import SwiftUI

enum DrivingSegment {
    case vehicles
    case drivingLicence
}

class DVLAAccountSummaryViewModel: ObservableObject {
    let vehiclesViewModel: VehiclesViewModel
    let licenceViewModel: DrivingLicenceViewModel
    @Published var selectedScreen: DrivingSegment = .vehicles
    let widgetTitle = String.dvla.localized("vehiclesTabTitle")
    let vehiclesTabTitle = String.dvla.localized("vehiclesTabTitle")
    let licenceTabTitle = String.dvla.localized("licenceTabTitle")

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
