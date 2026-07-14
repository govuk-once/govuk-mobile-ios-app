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
    private let statusFormatter = DVLAValidityStatusFormatter()
    private let specFormatter: VehicleSpecFormatterInterface
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
        let moreOptionsAccessibilityLabel = String(
            localized: .DVLA.moreOptionsButtonAccessibilityLabel
        )
        let taxValidityVehicle = TaxValidityVehicle(
            taxStatus: vehicle.taxStatus,
            sornStart: vehicle.sornStart,
            taxedUntil: vehicle.taxedUntil,
            currentLicencePaymentMethod: vehicle.currentLicencePaymentMethod
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
            addressAccessibilityLabel: keeperAddress ?? "",
            regNumberAccessibilityLabelPrefix: regNumberAccessibilityLabelPrefix,
            moreOptionsAccessibilityLabel: moreOptionsAccessibilityLabel
        )
    }

    @MainActor
    private func taxStatusViewModel(
        _ vehicle: TaxValidityVehicle
    ) -> ValidityStatusViewModel {
        let builder = TaxStatusViewModelBuilder(
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

    // swiftlint:disable:next function_body_length
    private func specificationSection(
        _ vehicle: CustomerVehicleDetails.Vehicle
    ) -> GroupedListSection {
        let engineSize: AccessibleString = specFormatter.formatEngineSize(
            from: vehicle.engineCapacity
        )
        let emissions: AccessibleString = specFormatter.formatEmissions(
            from: vehicle.exhaustEmissionsCo2
        )
        return GroupedListSection(
            heading: nil,
            rows: [
                InformationRow(
                    id: "vehicle.make.row",
                    title: String(localized: .DVLA.vehicleMake),
                    body: nil,
                    detail: vehicle.make
                ),
                InformationRow(
                    id: "vehicle.model.row",
                    title: String(localized: .DVLA.vehicleModel),
                    body: nil,
                    detail: specFormatter.formatModel(from: vehicle.model)
                ),
                InformationRow(
                    id: "vehicle.yearOfFirstRegistration.row",
                    title: String(localized: .DVLA.firstRegistered),
                    body: nil,
                    detail: specFormatter.formatYearOfFirstRegistration(
                        from: vehicle.dateOfFirstRegistration
                    )
                ),
                InformationRow(
                    id: "vehicle.fuelType.row",
                    title: String(localized: .DVLA.fuelType),
                    body: nil,
                    detail: specFormatter.formatFuelTypeLong(from: vehicle.fuelType)
                ),
                InformationRow(
                    id: "vehicle.colour.row",
                    title: String(localized: .DVLA.colour),
                    body: nil,
                    detail: specFormatter.formatColour(
                        primary: vehicle.colour,
                        secondary: vehicle.secondaryColour
                    )
                ),
                InformationRow(
                    id: "vehicle.engineSize.row",
                    title: String(localized: .DVLA.engineSize),
                    body: nil,
                    detail: engineSize.displayValue,
                    accessibilityLabel: String(
                        localized: .DVLA.engineSizeAccessibilityLabel(
                            value: engineSize.accessibilityLabel
                        )
                    )
                ),
                InformationRow(
                    id: "vehicle.emissions.row",
                    title: String(localized: .DVLA.co2Emissions),
                    body: nil,
                    detail: emissions.displayValue,
                    accessibilityLabel: String(
                        localized: .DVLA.emissionsAccessibilityLabel(
                            value: emissions.accessibilityLabel
                        )
                    )
                )
            ],
            footer: nil
        )
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
    let addressAccessibilityLabel: String
    let regNumberAccessibilityLabelPrefix: String
    let moreOptionsAccessibilityLabel: String
}
