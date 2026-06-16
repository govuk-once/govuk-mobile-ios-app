import Foundation
import GovKit

struct VehicleDetailViewModel: Identifiable {
    private let analyticsService: AnalyticsServiceInterface?
    let id: Int
    let registrationNumber: String
    let vehicleMake: String
    let vehicleModel: String
    let keeperFullName: String
    let keeperAddress: [String]
    let taxStatusViewModel: ValidityStatusViewModel
    let motStatusViewModel: ValidityStatusViewModel
    let vehicleSpecViewModel: VehicleSpecViewModel
    let specificationSection: GroupedListSection
    let addressAccessibilityLabel: String
    let regNumberAccessibilityLabelPrefix = String(
        localized: .DVLA.registrationNumberAccessibilityLabelPrefix
    )
    let moreOptionsAccessibilityLabel = String(
        localized: .DVLA.moreOptionsButtonAccessibilityLabel
    )

    func trackScreen(screen: TrackableScreen) {
        analyticsService?.track(screen: screen)
    }

    // todo: move formatting out of this init?
    // swiftlint:disable:next function_body_length
    init(analyticsService: AnalyticsServiceInterface?,
         vehicle: CustomerSummary.Vehicle,
         statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter(),
         specFormatter: VehicleSpecFormatter = VehicleSpecFormatter()
    ) {
        self.analyticsService = analyticsService
        self.id = vehicle.vehicleId
        self.registrationNumber = vehicle.registrationNumber
        self.vehicleMake = vehicle.make
        self.vehicleModel = specFormatter.formatModel(from: vehicle.model)
        self.taxStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("taxStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.taxedUntil)
        )
        self.motStatusViewModel = ValidityStatusViewModel(
            title: String.dvla.localized("motStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.motExpiryDate)
        )
        let fullName = [
            vehicle.keeper?.title,
            vehicle.keeper?.firstNames,
            vehicle.keeper?.lastName
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        .capitalized
        self.keeperFullName = fullName
        let driverAddress = vehicle.keeper?.address?.unstructuredAddress
        let addressArray = [
            driverAddress?.line1?.capitalized,
            driverAddress?.line2?.capitalized,
            driverAddress?.line3?.capitalized,
            driverAddress?.line4?.capitalized,
            driverAddress?.line5?.capitalized,
            driverAddress?.postcode
        ]
        .compactMap { $0 }
        self.keeperAddress = addressArray
        self.addressAccessibilityLabel = addressArray.joined(separator: ", ")
        self.vehicleSpecViewModel = VehicleSpecViewModel(
            colour: vehicle.colour.capitalized,
            fuelTypeIcon: specFormatter.getIconForFuelType(vehicle.fuelType),
            fuelTypeName: specFormatter.formatFuelTypeShort(from: vehicle.fuelType),
            year: specFormatter.formatYearOfFirstRegistration(from: vehicle.dateOfFirstRegistration)
        )
        self.specificationSection = GroupedListSection(
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
                    detail: specFormatter.formatEngineSize(from: vehicle.engineCapacity)
                ),
                // todo: override accessibility label
                InformationRow(
                    id: "vehicle.emissions.row",
                    title: String(localized: .DVLA.co2Emissions),
                    body: nil,
                    detail: specFormatter.formatEmissions(from: vehicle.exhaustEmissions)
                )
            ],
            footer: nil
        )
    }
}
