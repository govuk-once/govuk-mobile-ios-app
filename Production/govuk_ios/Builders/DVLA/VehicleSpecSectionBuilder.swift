import Foundation
import GovKit

struct VehicleSpecSectionBuilder {
    private let specFormatter: VehicleSpecFormatterInterface

    init(specFormatter: VehicleSpecFormatterInterface) {
        self.specFormatter = specFormatter
    }

    // swiftlint:disable:next function_body_length
    func makeSection(
        for specs: VehicleSpecData
    ) -> GroupedListSection {
        let engineSize: AccessibleString = specFormatter.formatEngineSize(
            from: specs.engineCapacity
        )
        let emissions = specFormatter.formatEmissions(
            from: specs.exhaustEmissionsCo2
        )

        let rows: [GroupedListRow?] =
        [
            InformationRow(
                id: "vehicle.make.row",
                title: String(localized: .DVLA.vehicleMake),
                body: nil,
                detail: specs.make
            ),
            // only show model row for customer vehicles
            specs.shouldDisplayModelRow ?
            InformationRow(
                id: "vehicle.model.row",
                title: String(localized: .DVLA.vehicleModel),
                body: nil,
                detail: specFormatter.formatModel(from: specs.model)
            ): nil,
            InformationRow(
                id: "vehicle.yearOfFirstRegistration.row",
                title: String(localized: .DVLA.firstRegistered),
                body: nil,
                detail: specFormatter.formatDateOfFirstRegistration(
                    specs.dateOfFirstRegistration
                )
            ),
            InformationRow(
                id: "vehicle.fuelType.row",
                title: String(localized: .DVLA.fuelType),
                body: nil,
                detail: specFormatter.formatFuelTypeLong(from: specs.fuelType)
            ),
            InformationRow(
                id: "vehicle.colour.row",
                title: String(localized: .DVLA.colour),
                body: nil,
                detail: specFormatter.formatColour(
                    primary: specs.colour,
                    secondary: specs.secondaryColour
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
                detail: emissions,
                accessibilityLabel: String(
                    localized: .DVLA.emissionsAccessibilityLabel(
                        value: emissions
                    )
                )
            )
        ]
        return GroupedListSection(
            heading: nil,
            rows: rows.compactMap { $0 },
            footer: nil
        )
    }
}
