import Foundation
import GovKit

// swiftlint:disable:next type_body_length
final class DVLAAccountViewModel: ObservableObject {
    @Published private(set) var sections = [GroupedListSection]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published private(set) var alertMessage: String = ""
    private let dateFormatter = DateFormatter.dvlaAccount

    private var drivingLicence: DrivingLicence?
    private let dvlaService: DVLAServiceInterface
    private let viewType: DVLAAccountViewType

    init(dvlaService: DVLAServiceInterface,
         viewType: DVLAAccountViewType) {
        self.dvlaService = dvlaService
        self.viewType = viewType
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    @MainActor func fetchContent() async {
        isLoading = true
        switch viewType {
        case .drivingLicence:
            let result = await dvlaService.fetchDrivingLicence()
            if case .success(let drivingLicence) = result {
                sections = [createSection(for: drivingLicence)]
            }
            handleError(result.getError())
        case .driverSummary:
            let result = await dvlaService.fetchDriverSummary()
            if case .success(let driverSummary) = result {
                sections = [createSection(for: driverSummary)]
            }
            handleError(result.getError())
        case .customerSummary:
            let result = await dvlaService.fetchCustomerSummary()
            if case .success(let customerSummary) = result {
                sections = [
                    createSection(for: customerSummary.customerResponse.customer),
                    createSection(for: customerSummary.vehicles)
                ]
            }
            handleError(result.getError())
        case .vehicle:
            // hard coded reg number, for proof of concept
            let result = await dvlaService.fetchVehicle(registration: "AA19AMP")
            if case .success(let vehicle) = result {
                sections = [createSection(for: vehicle)]
            }
            handleError(result.getError())
        case .shareCodeList:
            let result = await dvlaService.fetchShareCodes()
            if case .success(let response) = result {
                sections = [
                    createSection(
                        for: response.shareCodes,
                        title: "Check codes"
                    )
                ]
            }
            handleError(result.getError())
        case .createShareCode:
            let result = await dvlaService.createShareCode()
            if case .success(let response) = result {
                sections = [
                    createSection(
                        for: [response.shareCode],
                        title: "New check code"
                    )
                ]
            }
            handleError(result.getError())
        }
        isLoading = false
    }

    @MainActor
    func handleShareCodeAlertDismissed() async {
        showAlert = false
        alertMessage = ""
        await fetchContent()
    }

    @MainActor
    func cancelShareCode(_ shareCode: ShareCode) async {
        isLoading = true
        let result = await dvlaService.cancelShareCode(id: shareCode.tokenId)
        if case .success = result {
            alertMessage = "Check code cancelled successfully"
            showAlert = true
        } else {
            isLoading = false
            handleError(result.getError())
        }
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

    private func createSection(
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

    private func createSection(
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

    private func createSection(
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

    private func createSection(
        for vehicles: [CustomerSummary.Vehicle]
    ) -> GroupedListSection {
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
            rows = vehicles.map { createRow(for: $0) }
        }
        return GroupedListSection(
            heading: GroupedListHeader(
                title: "Vehicles"
            ),
            rows: rows,
            footer: nil
        )
    }

    private func createRow(for vehicle: CustomerSummary.Vehicle) -> InformationRow {
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

    // VES API
    // swiftlint:disable:next function_body_length
    private func createSection(for vehicle: Vehicle) -> GroupedListSection {
        return GroupedListSection(
            heading: GroupedListHeader(
                title: vehicle.registrationNumber
            ),
            rows: [
                InformationRow(
                    id: "vehicle.make.row",
                    title: "Make",
                    body: vehicle.make,
                    detail: ""
                ),
                InformationRow(
                    id: "vehicle.model.row",
                    title: "Model",
                    body: vehicle.model ?? "nil",
                    detail: ""
                ),
                InformationRow(
                    id: "vehicle.colour.row",
                    title: "Colour",
                    body: vehicle.colour,
                    detail: ""
                ),
                InformationRow(
                    id: "vehicle.fuelType.row",
                    title: "Fuel type",
                    body: vehicle.fuelType,
                    detail: ""
                ),
                InformationRow(
                    id: "vehicle.motStatus.row",
                    title: "MOT Status",
                    body: vehicle.motStatus,
                    detail: ""
                ),
                InformationRow(
                    id: "vehicle.taxStatus.row",
                    title: "Tax Status",
                    body: vehicle.taxStatus,
                    detail: ""
                ),
                InformationRow(
                    id: "vehicle.taxDue.row",
                    title: "Tax Due",
                    body: dateFormatter.string(
                        from: vehicle.taxDueDate
                    ),
                    detail: ""
                )
            ], footer: nil
        )
    }

    private func createSection(
        for shareCodes: [ShareCode],
        title: String
    ) -> GroupedListSection {
        let rows = shareCodes.map { shareCode in
            let isValid = shareCode.state == "valid"
            let row = DetailRow(
                id: "shareCode.\(shareCode.tokenId).row",
                title: """
                    Token: \(shareCode.token)
                    Created: \(dateFormatter.string(from: shareCode.created))
                    Expiry: \(dateFormatter.string(from: shareCode.expiry))
                    State: \(shareCode.state)
                    """,
                body: isValid ? "Cancel" : "",
                accessibilityHint: "",
                action: { [weak self] in
                    self?.handleCancelAction(for: shareCode)
                }
            )
            return row
        }
        return GroupedListSection(
            heading: GroupedListHeader(
                title: title
            ),
            rows: rows,
            footer: nil
        )
    }

    private func handleCancelAction(for shareCode: ShareCode) {
        guard shareCode.state == "valid" else { return }
        Task {
            await cancelShareCode(shareCode)
        }
    }

    private var dvlaAccountErrorViewModel: AppErrorViewModel {
        .dvlaAccountErrorWithAction { [weak self] in
            Task {
                await self?.fetchContent()
            }
        }
    }
}
