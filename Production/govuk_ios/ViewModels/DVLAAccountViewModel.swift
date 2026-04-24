import Foundation
import GovKit

class DVLAAccountViewModel: ObservableObject {
    @Published private(set) var sections = [GroupedListSection]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var isLoading: Bool = false
    private let dateFormatter = DateFormatter.dvlaAccount

    private var drivingLicence: DrivingLicence?
    private let dvlaService: DVLAServiceInterface
    private let viewType: DVLAAccountViewType

    init(dvlaService: DVLAServiceInterface,
         viewType: DVLAAccountViewType) {
        self.dvlaService = dvlaService
        self.viewType = viewType
    }

    @MainActor
    func fetchContent() async {
        isLoading = true
        switch viewType {
        case .drivingLicence:
            let result = await dvlaService.fetchDrivingLicence()
            if case .success(let drivingLicence) = result {
                sections = [section(for: drivingLicence)]
            }
            handleError(result.getError())
        case .driverSummary:
            let result = await dvlaService.fetchDriverSummary()
            if case .success(let driverSummary) = result {
                sections = [section(for: driverSummary)]
            }
            handleError(result.getError())
        case .customerSummary:
            let result = await dvlaService.fetchCustomerSummary()
            if case .success(let customerSummary) = result {
                sections = [
                    section(for: customerSummary.customerResponse.customer),
                    section(for: customerSummary.vehicles)
                ]
            }
        }
        isLoading = false
    }

    private func handleError(_ error: DVLAError?) {
        guard let error else {
            errorViewModel = nil
            return
        }
        if error == .networkUnavailable {
            errorViewModel = AppErrorViewModel.networkUnavailable(
                action: {
                    Task {
                        await self.fetchContent()
                    }
                }
            )
        } else {
            errorViewModel = dvlaAccountErrorViewModel
        }
    }

    private func section(
        for drivingLicence: DrivingLicence
    ) -> GroupedListSection {
        return GroupedListSection(
            heading: GroupedListHeader(
                title: String.dvla.localized("dvlaAccountTitle")
            ),
            rows: [
                InformationRow(
                    id: "licence.number.row",
                    title: "Licence number",
                    body: drivingLicence.driver.licenceNo,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.type.row",
                    title: "Type",
                    body: drivingLicence.licence.type,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.status.row",
                    title: "Status",
                    body: drivingLicence.licence.status,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.valid.from.row",
                    title: "Valid from",
                    body: dateFormatter.string(
                        from: drivingLicence.token.validFromDate
                    ),
                    detail: ""
                ),
                InformationRow(
                    id: "licence.valid.to.row",
                    title: "Valid to",
                    body: dateFormatter.string(
                        from: drivingLicence.token.validToDate
                    ),
                    detail: ""
                )
            ], footer: nil
        )
    }

    private func section(
        for driverSummary: DriverSummary
    ) -> GroupedListSection {
        return GroupedListSection(
            heading: GroupedListHeader(
                title: "Driver summary"
            ),
            rows: [
                InformationRow(
                    id: "licence.number.row",
                    title: "Licence number",
                    body: driverSummary.response.driver.licenceNo,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.status.row",
                    title: "Status",
                    body: driverSummary.response.licence.status,
                    detail: ""
                ),
                InformationRow(
                    id: "driver.firstNames.row",
                    title: "First names",
                    body: driverSummary.response.driver.firstNames,
                    detail: ""
                ),
                InformationRow(
                    id: "driver.lastName.row",
                    title: "Last name",
                    body: driverSummary.response.driver.lastName,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.penaltyPoints.row",
                    title: "Penalty points",
                    body: "\(driverSummary.response.driver.penaltyPoints)",
                    detail: ""
                ),
                InformationRow(
                    id: "licence.valid.to.row",
                    title: "Valid to",
                    body: dateFormatter.string(
                        from: driverSummary.response.token.validToDate
                    ),
                    detail: ""
                )
            ], footer: nil
        )
    }

    private func section(
        for customer: Customer
    ) -> GroupedListSection {
        return GroupedListSection(
            heading: GroupedListHeader(
                title: "Customer summary"
            ),
            rows: [
                InformationRow(
                    id: "customer.firstNames.row",
                    title: "First names",
                    body: customer.individualDetails.firstNames,
                    detail: ""
                ),
                InformationRow(
                    id: "customer.lastName.row",
                    title: "Last name",
                    body: customer.individualDetails.lastName,
                    detail: ""
                ),
                InformationRow(
                    id: "customer.type.row",
                    title: "Customer type",
                    body: customer.customerType,
                    detail: ""
                )
            ], footer: nil
        )
    }

    private func section(for vehicles: [Vehicle]) -> GroupedListSection {
        var rows = [InformationRow]()
        if vehicles.count == 0 {
            rows = [
                InformationRow(
                    id: "vehicle.empty.row",
                    title: "None",
                    body: nil,
                    detail: ""
                )
            ]
        } else {
            rows = vehicles.map { row(for: $0) }
        }
        return GroupedListSection(
            heading: GroupedListHeader(
                title: "Vehicles"
            ),
            rows: rows,
            footer: nil
        )
    }

    private func row(for vehicle: Vehicle) -> InformationRow {
        InformationRow(
            id: "vehicle.\(vehicle.vehicleId).row",
            title: """
                Registration number: \(vehicle.registrationNumber)
                Make: \(vehicle.make)
                Model: \(vehicle.model ?? "nil")
                Tax status:  \(vehicle.taxStatus)
                MOT status: \(vehicle.motStatus)
                """,
            body: nil,
            detail: ""
        )
    }

    private var dvlaAccountErrorViewModel: AppErrorViewModel {
        .dvlaAccountErrorWithAction { [weak self] in
            Task {
                await self?.fetchContent()
            }
        }
    }
}
