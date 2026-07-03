import Foundation
import GovKit

final class DVLAAccountViewModel: ObservableObject {
    @Published private(set) var sections = [GroupedListSection]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published private(set) var alertMessage: String = ""
    private let dateFormatter = DateFormatter.dvlaAccount

    private let dvlaService: DVLAServiceInterface
    private let viewType: DVLAAccountViewType

    init(dvlaService: DVLAServiceInterface,
         viewType: DVLAAccountViewType) {
        self.dvlaService = dvlaService
        self.viewType = viewType
    }

    @MainActor func fetchContent() async {
        isLoading = true
        switch viewType {
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
            let showCancelButton = shareCode.state == "valid"
            && viewType == .shareCodeList
            let row = DetailRow(
                id: "shareCode.\(shareCode.tokenId).row",
                title: """
                    Token: \(shareCode.token)
                    Created: \(dateFormatter.string(from: shareCode.created))
                    Expiry: \(dateFormatter.string(from: shareCode.expiry))
                    State: \(shareCode.state)
                    """,
                body: showCancelButton ? "Cancel" : "",
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
        guard shareCode.state == "valid",
        viewType == .shareCodeList else { return }
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
