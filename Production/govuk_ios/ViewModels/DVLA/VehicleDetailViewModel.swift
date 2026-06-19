import Foundation
import GovKit

struct VehicleDetailViewModel: Identifiable {
    private let vehicle: CustomerSummary.Vehicle
    private let analyticsService: AnalyticsServiceInterface?
    private let statusFormatter = DVLAValidityStatusFormatter()
    private let specFormatter: VehicleSpecFormatterInterface

    var id: Int {
        vehicle.vehicleId
    }
    var registrationNumber: String {
        vehicle.registrationNumber
    }
    var vehicleMake: String {
        vehicle.make
    }
    var vehicleModel: String {
        specFormatter.formatModel(from: vehicle.model)
    }
    var keeperFullName: String {
        [
            vehicle.keeper?.title,
            vehicle.keeper?.firstNames,
            vehicle.keeper?.lastName
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
    var keeperAddress: [String] {
        let driverAddress = vehicle.keeper?.address?.unstructuredAddress
        return [
            driverAddress?.line1?.capitalized,
            driverAddress?.line2?.capitalized,
            driverAddress?.line3?.capitalized,
            driverAddress?.line4?.capitalized,
            driverAddress?.line5?.capitalized,
            driverAddress?.postcode
        ]
        .compactMap { $0 }
    }
    var taxStatusViewModel: ValidityStatusViewModel {
        .init(
            title: String.dvla.localized("taxStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.taxedUntil)
        )
    }
    var motStatusViewModel: ValidityStatusViewModel {
        .init(
            title: String.dvla.localized("motStatusTitle"),
            status: statusFormatter.formatStatus(from: vehicle.motExpiryDate)
        )
    }
    var vehicleSpecViewModel: VehicleSpecViewModel {
        .init(
            colour: vehicle.colour.capitalized,
            fuelTypeIcon: specFormatter.getIconForFuelType(vehicle.fuelType),
            fuelTypeName: specFormatter.formatFuelTypeShort(from: vehicle.fuelType),
            year: specFormatter.formatYearOfFirstRegistration(from: vehicle.dateOfFirstRegistration)
        )
    }
    var specificationSection: GroupedListSection {
        GroupedListSection(
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
    var addressAccessibilityLabel: String {
        keeperAddress.joined(separator: ", ")
    }
    let regNumberAccessibilityLabelPrefix = String(
        localized: .DVLA.registrationNumberAccessibilityLabelPrefix
    )
    let moreOptionsAccessibilityLabel = String(
        localized: .DVLA.moreOptionsButtonAccessibilityLabel
    )

    private var engineSize: AccessibleString {
        specFormatter.formatEngineSize(from: vehicle.engineCapacity)
    }

    private var emissions: AccessibleString {
        specFormatter.formatEmissions(from: vehicle.exhaustEmissions)
    }

    init(analyticsService: AnalyticsServiceInterface?,
         vehicle: CustomerSummary.Vehicle,
         specFormatter: VehicleSpecFormatterInterface = VehicleSpecFormatter()
    ) {
        self.vehicle = vehicle
        self.analyticsService = analyticsService
        self.specFormatter = specFormatter
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService?.track(screen: screen)
    }
}
