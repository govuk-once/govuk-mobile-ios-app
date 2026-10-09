import Foundation
import GovKit

final class VehicleDetailViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded(ViewVehicleDetails)
        case error(InlineActionErrorViewModel)
    }

    @Published private(set) var viewState: ViewState = .loading

    private let vehicleId: Int
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let configService: AppConfigServiceInterface
    private let openURLAction: (URL) -> Void
    private let specFormatter: VehicleSpecFormatterInterface
    private let specSectionBuilder: VehicleSpecSectionBuilder
    private var vehicleLoaded = false

    let loadingAccessibilityLabel = String(localized: .DVLA.loadingVehicleAccessibilityLabel)

    init(
        vehicleId: Int,
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        openURLAction: @escaping (URL) -> Void,
        specFormatter: VehicleSpecFormatterInterface = VehicleSpecFormatter()
    ) {
        self.vehicleId = vehicleId
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.openURLAction = openURLAction
        self.specFormatter = specFormatter
        self.specSectionBuilder = VehicleSpecSectionBuilder(specFormatter: specFormatter)
    }

    @MainActor
    func viewDidAppear() async {
        guard !vehicleLoaded else { return }
        await fetchVehicle()
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    @MainActor
    private func fetchVehicle() async {
        viewState = .loading

        let result = await dvlaService.fetchCustomerVehicleDetails(vehicleId)

        switch result {
        case .success(let vehicleReponse):
            viewState = .loaded(
                makeViewVehicleDetails(vehicleReponse.customerVehicleDetails)
            )
            vehicleLoaded = true
        case .failure:
            viewState = .error(vehicleErrorViewModel)
            vehicleLoaded = false
        }
    }

    @MainActor
    private func makeViewVehicleDetails(
        _ vehicle: CustomerVehicleDetails.Vehicle
    ) -> ViewVehicleDetails {
        let keeperAddress = vehicle.keeperFullAddress
        let regNumberAccessibilityLabelPrefix = String(
            localized: .DVLA.registrationNumberAccessibilityLabelPrefix
        )
        let taxValidityVehicle = TaxValidityVehicle(
            taxStatus: vehicle.taxStatus,
            sornStart: vehicle.sornStart,
            taxedUntil: vehicle.taxedUntil,
            currentLicencePaymentMethod: vehicle.currentLicencePaymentMethod
        )

        let menuItemsBuilder = VehicleMenuItemsBuilder(
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )

        return ViewVehicleDetails(
            keeperFullName: keeperFullName(vehicle),
            keeperAddress: keeperAddress ?? "",
            make: vehicle.make,
            model: vehicle.model ?? "",
            registrationNumber: vehicle.registrationNumber,
            taxStatusViewModel: taxStatusViewModel(taxValidityVehicle),
            motStatusViewModel: motStatusViewModel(vehicle),
            vehicleSpecViewModel: specViewModel(vehicle),
            specificationSection: specificationSection(vehicle),
            menuItems: menuItemsBuilder.makeMenuItems(
                sornStart: vehicle.sornStart,
                taxStatus: vehicle.taxStatus
            ),
            addressAccessibilityLabel: keeperAddress ?? "",
            regNumberAccessibilityLabelPrefix: regNumberAccessibilityLabelPrefix
        )
    }

    @MainActor
    private func taxStatusViewModel(
        _ vehicle: TaxValidityVehicle
    ) -> ValidityStatusViewModel {
        let builder = TaxStatusViewModelBuilder(
            isOwnedVehicle: true,
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        return builder.makeViewModel(
            vehicle: vehicle
        )
    }

    @MainActor
    private func motStatusViewModel(
        _ vehicle: CustomerVehicleDetails.Vehicle
    ) -> ValidityStatusViewModel {
        let builder = MotStatusViewModelBuilder(
            isOwnedVehicle: true,
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        return builder.makeViewModel(
            vehicle: MotStatusVehicle(
                motStatus: vehicle.motStatus,
                motExpiryDate: vehicle.motExpiryDate,
                registrationNumber: vehicle.registrationNumber
            )
        )
    }

    private func specViewModel(
        _ vehicle: CustomerVehicleDetails.Vehicle
    ) -> VehicleSpecViewModel {
        .init(
            colour: vehicle.colour.capitalized,
            fuelTypeIcon: specFormatter.getIconForFuelType(vehicle.fuelType),
            fuelTypeName: specFormatter.formatFuelTypeShort(from: vehicle.fuelType),
            year: specFormatter.formatYearOfFirstRegistration(from: vehicle.dateOfFirstRegistration)
        )
    }

    private func keeperFullName(
        _ vehicle: CustomerVehicleDetails.Vehicle
    ) -> String {
        [
            vehicle.keeperTitle,
            vehicle.keeperFirstNames,
            vehicle.keeperLastName
        ]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    private func specificationSection(
        _ vehicle: CustomerVehicleDetails.Vehicle
    ) -> GroupedListSection {
        let specData = VehicleSpecData(vehicle: vehicle)
        return specSectionBuilder.makeSection(for: specData)
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

    private var vehicleErrorViewModel: InlineActionErrorViewModel {
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

struct ViewVehicleDetails {
    let keeperFullName: String
    let keeperAddress: String
    let make: String
    let model: String
    let registrationNumber: String
    let taxStatusViewModel: ValidityStatusViewModel
    let motStatusViewModel: ValidityStatusViewModel
    let vehicleSpecViewModel: VehicleSpecViewModel
    let specificationSection: GroupedListSection
    let menuItems: [DvlaMenuItemViewModel]
    let addressAccessibilityLabel: String
    let regNumberAccessibilityLabelPrefix: String
}
