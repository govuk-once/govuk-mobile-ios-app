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
    private let detailAction: (CustomerSummary.Vehicle) -> Void
    private let openURLAction: (URL) -> Void
    let loadingAccessibilityLabel = String.dvla.localized(
        "loadingVehiclesAccessibilityLabel"
    )

    init(viewState: ViewState = .loading,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         configService: AppConfigServiceInterface,
         detailAction: @escaping (CustomerSummary.Vehicle) -> Void,
         openURLAction: @escaping (URL) -> Void) {
        self.viewState = viewState
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.detailAction = detailAction
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
            let vehicleSummaryViewModels = customerSummary.vehicles.map { vehicle in
                VehicleSummaryViewModel(
                    vehicle: vehicle,
                    detailAction: { [weak self] in
                        self?.trackDetailButtonTapped()
                        self?.detailAction(vehicle)
                    },
                    openURLAction: openURLAction,
                    configService: configService,
                    analyticsService: analyticsService
                )
            }
            hasLoadedVehicles = true
            viewState = .loaded(vehicles: vehicleSummaryViewModels)
        case .failure:
            viewState = .error(dvlaAccountErrorViewModel)
        }
    }

    private func trackDetailButtonTapped() {
        let event = AppEvent.buttonNavigation(
            text: "Details",
            external: false,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }

    func addNewVehiclesAction() {
        let url = configService.dvlaUrls?.addVehicle ??
        Constants.API.defaultDvlaAddVehicleUrl
        openURLAction(url)
        let event = AppEvent.drivingAccountCardNavigation(
            text: "Add your vehicle",
            url: url.absoluteString
        )
        analyticsService.track(event: event)
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
