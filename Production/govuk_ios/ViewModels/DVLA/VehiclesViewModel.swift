import GovKit
import SwiftUI

class VehiclesViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded(vehicles: [VehicleSummaryViewModel])
        case error(AppErrorViewModel)
    }

    @Published private(set) var viewState: ViewState

    private var hasLoadedVehicles = false
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let configService: AppConfigServiceInterface
    private let openURLAction: (URL) -> Void
    let loadingAccessibilityLabel = String.dvla.localized(
        "loadingVehiclesAccessibilityLabel"
    )

    init(viewState: ViewState = .loading,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         configService: AppConfigServiceInterface,
         openURLAction: @escaping (URL) -> Void) {
        self.viewState = viewState
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.openURLAction = openURLAction
    }

    @MainActor
    func viewDidAppear() async {
        if !hasLoadedVehicles {
            await fetchVehicles()
        }
    }

    @MainActor
    private func fetchVehicles() async {
        viewState = .loading
        let result = await dvlaService.fetchCustomerSummary()

        switch result {
        case .success(let customerSummary):
            let vehicleSummaryViewModels = customerSummary.vehicles.map {
                VehicleSummaryViewModel(vehicle: $0)
            }
            hasLoadedVehicles = true
            viewState = .loaded(vehicles: vehicleSummaryViewModels)
        case .failure:
            viewState = .error(dvlaAccountErrorViewModel)
        }
    }

    func addNewVehiclesAction() {
        openURLAction(configService.dvlaUrls?.addVehicle ?? Constants.API.defaultDvlaAddVehicleAUrl)
        hasLoadedVehicles = false
    }

    private var dvlaAccountErrorViewModel: AppErrorViewModel {
        .dvlaAccountErrorWithAction { [weak self] in
            Task {
                await self?.fetchVehicles()
            }
        }
    }
}
