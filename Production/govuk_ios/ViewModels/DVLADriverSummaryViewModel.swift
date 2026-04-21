import Foundation
import GovKit

class DVLADriverSummaryViewModel: ObservableObject {
    @Published private(set) var sections = [GroupedListSection]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var isLoading: Bool = false
    private let dateFormatter = DateFormatter.dvlaAccount

    private var driverSummary: DriverSummary?
    private let dvlaService: DVLAServiceInterface

    init(dvlaService: DVLAServiceInterface) {
        self.dvlaService = dvlaService
    }

    @MainActor
    func fetchDriverSummary() async {
        isLoading = true
        let result = await dvlaService.fetchDriverSummary()
        if case .success(let driverSummary) = result {
            self.driverSummary = driverSummary
            updateContent()
        }
        handleError(result.getError())
        isLoading = false
    }

    private func updateContent() {
        sections = [
            driverSummarySection
        ].compactMap { $0 }
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
                        await self.fetchDriverSummary()
                    }
                }
            )
        } else {
            errorViewModel = driverSummaryErrorViewModel
        }
    }

    private var driverSummarySection: GroupedListSection? {
        guard let driverSummary = driverSummary else { return nil }
        return GroupedListSection(
            heading: GroupedListHeader(
                title: "Driver summary"
            ),
            rows: [
                InformationRow(
                    id: "licence.number.row",
                    title: "Licence number",
                    body: driverSummary.driverViewResponse.driver.drivingLicenceNumber,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.status.row",
                    title: "Status",
                    body: driverSummary.driverViewResponse.licence.status,
                    detail: ""
                ),
                InformationRow(
                    id: "driver.firstNames.row",
                    title: "First names",
                    body: driverSummary.driverViewResponse.driver.firstNames,
                    detail: ""
                ),
                InformationRow(
                    id: "driver.lastName.row",
                    title: "Last name",
                    body: driverSummary.driverViewResponse.driver.lastName,
                    detail: ""
                ),
                InformationRow(
                    id: "licence.penaltyPoints.row",
                    title: "Penalty points",
                    body: "\(driverSummary.driverViewResponse.driver.penaltyPoints)",
                    detail: ""
                ),
                InformationRow(
                    id: "licence.valid.to.row",
                    title: "Valid to",
                    body: dateFormatter.string(
                        from: driverSummary.driverViewResponse.token.validToDate
                    ),
                    detail: ""
                )
            ], footer: nil
        )
    }

    private var driverSummaryErrorViewModel: AppErrorViewModel {
        .dvlaAccountErrorWithAction { [weak self] in
            Task {
                await self?.fetchDriverSummary()
            }
        }
    }
}
