import GovKit
import SwiftUI

class VehiclesViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded(vehicles: [VehicleSummaryViewModel])
        case error(InlineActionErrorViewModel)
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
            viewState = .error(vehiclesErrorViewModel)
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

    private func handleOpenURL(url: URL, buttonTitle: String) {
        trackOpenURLAction(url: url, buttonTitle: buttonTitle)
        openURLAction(url)
    }

    private func trackOpenURLAction(url: URL, buttonTitle: String) {
        let event = AppEvent.buttonNavigation(
            text: buttonTitle,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }

    func addNewVehiclesAction(largeCard: Bool) {
        let url = configService.dvlaUrls?.addVehicle ??
        Constants.API.defaultDvlaAddVehicleUrl
        openURLAction(url)

        let event: AppEvent
        if largeCard {
            event = AppEvent.drivingAccountCardNavigation(
                text: "Add your vehicle",
                url: url.absoluteString
            )
        } else {
            event = AppEvent.buttonNavigation(
                text: "Add vehicle",
                external: true,
                url: url.absoluteString,
                section: "Driving"
            )
        }
        analyticsService.track(event: event)

        hasLoadedVehicles = false
    }

    private var vehiclesErrorViewModel: InlineActionErrorViewModel {
        let url = configService.dvlaUrls?.account ?? Constants.API.defaultDvlaAccountUrl
        let buttonTitle = String(localized: .DVLA.vehicleSummaryErrorButtonTitle)
        let errorBody = String(
            localized: .DVLA.vehicleSummaryErrorBody(
                buttonTitle: buttonTitle,
                url: url.absoluteString
            )
        )
        return InlineActionErrorViewModel(
            title: String(localized: .DVLA.vehicleSummaryErrorTitle),
            markdownBody: errorBody,
            openURLAction: { [weak self] url in
                self?.handleOpenURL(url: url, buttonTitle: buttonTitle)
            }
        )
    }
}
