import Foundation
import GovKit

struct VehicleSummaryViewModel: Identifiable {
    let id: Int
    let registrationNumber: String
    let vehicleMake: String
    let vehicleModel: String
    let taxStatusViewModel: ValidityStatusViewModel
    let motStatusViewModel: ValidityStatusViewModel
    let detailAction: () -> Void
    let regNumberAccessibilityLabelPrefix = String(
        localized: .DVLA.registrationNumberAccessibilityLabelPrefix
    )
    private let sornStart: Date?
    private let taxStatus: TaxStatus?
    private let openURLAction: (URL) -> Void
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
}

extension VehicleSummaryViewModel {
    @MainActor
    init(
        vehicle: CustomerVehicles.Vehicle,
        specFormatter: VehicleSpecFormatter = VehicleSpecFormatter(),
        detailAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void,
        configService: AppConfigServiceInterface,
        analyticsService: AnalyticsServiceInterface
    ) {
        self.id = vehicle.vehicleId
        self.registrationNumber = vehicle.registrationNumber
        self.vehicleMake = vehicle.make
        self.vehicleModel = specFormatter.formatModel(from: vehicle.model)
        self.sornStart = vehicle.sornStart
        self.taxStatus = vehicle.taxStatus

        let builder = TaxStatusViewModelBuilder(
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        self.taxStatusViewModel = builder.makeViewModel(
            vehicle: TaxValidityVehicle(
                taxStatus: vehicle.taxStatus,
                sornStart: vehicle.sornStart,
                taxedUntil: vehicle.taxedUntil,
                currentLicencePaymentMethod: vehicle.currentLicencePaymentMethod
            )
        )
        let motBuilder = MotStatusViewModelBuilder(
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        self.motStatusViewModel = motBuilder.makeViewModel(
            vehicle: MotStatusVehicle(
                motStatus: vehicle.motStatus,
                motExpiryDate: vehicle.motExpiryDate,
                registrationNumber: vehicle.registrationNumber
            )
        )

        self.detailAction = detailAction
        self.openURLAction = openURLAction
        self.configService = configService
        self.analyticsService = analyticsService
    }
}

extension VehicleSummaryViewModel {
    var menuItems: [DvlaMenuItemViewModel] {
        let builder = VehicleMenuItemsBuilder(
            urls: configService.dvlaUrls,
            analyticsService: analyticsService,
            openURLAction: openURLAction
        )
        return builder.makeMenuItems(
            sornStart: sornStart,
            taxStatus: taxStatus
        )
    }
}
