import Foundation
import GovKit

struct VehicleCheckResultActions {
    let openURLAction: (URL) -> Void
    let searchAction: () -> Void
    let dismissAction: () -> Void
}

struct VehicleCheckResultViewModel {
    private let vehicle: VehicleEnquiryResponse.Vehicle
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let actions: VehicleCheckResultActions
    private let taxStatusViewModelBuilder: TaxStatusViewModelBuilder
    private let motStatusViewModelBuilder: MotStatusViewModelBuilder
    private let specSectionBuilder: VehicleSpecSectionBuilder
    private let specFormatter = VehicleSpecFormatter()

    let regNumberAccessibilityLabelPrefix = String(
        localized: .DVLA.registrationNumberAccessibilityLabelPrefix
    )

    var make: String {
        vehicle.make
    }

    var vehicleSpecViewModel: VehicleSpecViewModel {
        vehicleSpecViewModel(for: vehicle)
    }

    @MainActor
    var taxStatusViewModel: ValidityStatusViewModel {
        taxStatusViewModel(for: vehicle)
    }

    @MainActor
    var motStatusViewModel: ValidityStatusViewModel {
        motStatusViewModel(for: vehicle)
    }

    var registrationNumber: String {
        vehicle.registrationNumber
    }

    var specificationSection: GroupedListSection {
        specificationSection(for: vehicle)
    }

    var menuItems: [DvlaMenuItemViewModel] {
        menuItems(for: vehicle)
    }

    init(vehicle: VehicleEnquiryResponse.Vehicle,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         actions: VehicleCheckResultActions
    ) {
        self.vehicle = vehicle
        self.analyticsService = analyticsService
        self.configService = configService
        self.actions = actions
        self.taxStatusViewModelBuilder = TaxStatusViewModelBuilder(
            isOwnedVehicle: false,
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: actions.openURLAction
        )
        self.motStatusViewModelBuilder = MotStatusViewModelBuilder(
            isOwnedVehicle: false,
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: actions.openURLAction
        )
        self.specSectionBuilder = VehicleSpecSectionBuilder(specFormatter: specFormatter)
    }

    func dismiss() {
        trackDismissEvent()
        actions.dismissAction()
    }

    func search() {
        trackSearchEvent()
        actions.searchAction()
    }

    @MainActor
    private func taxStatusViewModel(
        for vehicle: VehicleEnquiryResponse.Vehicle
    ) -> ValidityStatusViewModel {
        let taxValidityVehicle = TaxValidityVehicle(
            taxStatus: vehicle.taxStatus,
            sornStart: nil,
            taxedUntil: vehicle.taxedUntil,
            currentLicencePaymentMethod: nil
        )
        return taxStatusViewModelBuilder.makeViewModel(vehicle: taxValidityVehicle)
    }

    @MainActor
    private func motStatusViewModel(
        for vehicle: VehicleEnquiryResponse.Vehicle
    ) -> ValidityStatusViewModel {
        let motStatusVehicle = MotStatusVehicle(
            motStatus: vehicle.motStatus,
            motExpiryDate: vehicle.motExpiryDate,
            registrationNumber: vehicle.registrationNumber
        )
        return motStatusViewModelBuilder.makeViewModel(vehicle: motStatusVehicle)
    }

    private func vehicleSpecViewModel(
        for vehicle: VehicleEnquiryResponse.Vehicle
    ) -> VehicleSpecViewModel {
        VehicleSpecViewModel(
            colour: vehicle.colour.capitalized,
            fuelTypeIcon: specFormatter.getIconForFuelType(vehicle.fuelType),
            fuelTypeName: specFormatter.formatFuelTypeShort(from: vehicle.fuelType),
            year: specFormatter.formatYearOfFirstRegistration(from: vehicle.dateOfFirstRegistration)
        )
    }

    private func specificationSection(
        for vehicle: VehicleEnquiryResponse.Vehicle
    ) -> GroupedListSection {
        let specData = VehicleSpecData(vehicle: vehicle)
        return specSectionBuilder.makeSection(for: specData)
    }

    private func openSoldVehicleURL(_ text: String) {
        let url = configService.dvlaUrls?.soldVehicle ??
        Constants.API.defaultDvlaSoldVehicleUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openBuyingUsedCarChecksURL(_ text: String) {
        let url = configService.dvlaUrls?.buyingUsedCarChecks ??
        Constants.API.defaultBuyingUsedCarChecksUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openReportAbandonedVehicleURL(_ text: String) {
        let url = configService.dvlaUrls?.reportAbandonedVehicle ??
        Constants.API.defaultReportAbandonedVehicleUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openReportUntaxedVehicleURL(_ text: String) {
        let url = configService.dvlaUrls?.reportUntaxedVehicle ??
        Constants.API.defaultReportUntaxedVehicleUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openReportNoMotURL(_ text: String) {
        let url = configService.dvlaUrls?.reportNoMot ??
        Constants.API.defaultReportNoMotUrl
        openMenuURLAction(url: url, text: text)
    }

    private func openMenuURLAction(url: URL, text: String) {
        actions.openURLAction(url)
        trackUrlOpenEvent(url: url, text: text)
    }

    private func trackUrlOpenEvent(url: URL, text: String) {
        let event = AppEvent.buttonNavigation(
            text: text,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }

    private func trackDismissEvent() {
        let event = AppEvent.buttonNavigation(
            text: "Back",
            external: false,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }

    private func trackSearchEvent() {
        let event = AppEvent(
            name: "Navigation",
            params: [
                "type": "Button",
                "text": "Search",
                "action": "Open search number plate",
                "external": false,
                "section": "Driving"
            ]
        )
        analyticsService.track(event: event)
    }
}

// MARK: Menu items

extension VehicleCheckResultViewModel {
    // swiftlint:disable:next function_body_length
    private func menuItems(
        for vehicle: VehicleEnquiryResponse.Vehicle
    ) -> [DvlaMenuItemViewModel] {
        var items: [DvlaMenuItemViewModel] = []
        items.append(
            DvlaMenuItemViewModel(
                title: String(localized: .DVLA.vehicleMenuRegisterToYouTitle),
                accessibilityLabel: String(
                    localized: .DVLA.vehicleMenuRegisterToYouAccessibilityTitle
                ),
                openURLAction: { text in openSoldVehicleURL(text) }
            )
        )
        items.append(
            DvlaMenuItemViewModel(
                title: String(localized: .DVLA.vehicleMenuUsedCarChecksTitle),
                accessibilityLabel: String(localized: .DVLA.vehicleMenuUsedCarChecksTitle),
                openURLAction: { text in openBuyingUsedCarChecksURL(text) }
            )
        )

        items.append(
            DvlaMenuItemViewModel(
                title: String(localized: .DVLA.vehicleMenuReportAbandonedTitle),
                accessibilityLabel: String(
                    localized: .DVLA.vehicleMenuReportAbandonedAccessibilityLabel
                ),
                openURLAction: { text in openReportAbandonedVehicleURL(text) }
            )
        )

        let notTaxedStatuses: Set<TaxStatus> = [.untaxed, .sorn, .notTaxedForOnRoadUse]
        if vehicle.motStatus == .valid,
            let taxStatus = vehicle.taxStatus,
            notTaxedStatuses.contains(taxStatus) {
            items.append(
                DvlaMenuItemViewModel(
                    title: String(localized: .DVLA.vehicleMenuReportOnRoadTitle),
                    accessibilityLabel: String(
                        localized: .DVLA.vehicleMenuReportOnRoadAccessibilityLabel
                    ),
                    openURLAction: { text in openReportUntaxedVehicleURL(text) }
                )
            )
        } else if vehicle.motStatus == .notValid {
            items.append(
                DvlaMenuItemViewModel(
                    title: String(localized: .DVLA.vehicleMenuReportOnRoadTitle),
                    accessibilityLabel: String(
                        localized: .DVLA.vehicleMenuReportOnRoadAccessibilityLabel
                    ),
                    openURLAction: { text in openReportNoMotURL(text) }
                )
            )
        }
        return items
    }
}
