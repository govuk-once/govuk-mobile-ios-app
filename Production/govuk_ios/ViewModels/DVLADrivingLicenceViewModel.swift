import Foundation
import GovKit

class DVLADrivingLicenceViewModel: ObservableObject {
    @Published private(set) var sections = [GroupedListSection]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var isLoading: Bool = false
    private let dateFormatter = DateFormatter.dvlaAccount

    private var drivingLicence: DrivingLicence?
    private let dvlaService: DVLAServiceInterface

    init(dvlaService: DVLAServiceInterface) {
        self.dvlaService = dvlaService
    }

    @MainActor
    func fetchDrivingLicence() async {
        isLoading = true
        let result = await dvlaService.fetchDrivingLicence()
        if case .success(let drivingLicence) = result {
            self.drivingLicence = drivingLicence
            updateContent()
        }
        handleError(result.getError())
        isLoading = false
    }

    private func updateContent() {
        sections = [
            drivingLicenceSection
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
                        await self.fetchDrivingLicence()
                    }
                }
            )
        } else {
            errorViewModel = drivingLicenseErrorViewModel
        }
    }

    private var drivingLicenceSection: GroupedListSection? {
        guard let drivingLicence = drivingLicence else { return nil }
        return GroupedListSection(
            heading: GroupedListHeader(
                title: String.dvla.localized("dvlaAccountTitle")
            ),
            rows: [
                InformationRow(
                    id: "licence.number.row",
                    title: "Licence number",
                    body: drivingLicence.driver.drivingLicenceNumber,
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

    private var drivingLicenseErrorViewModel: AppErrorViewModel {
        .dvlaAccountErrorWithAction { [weak self] in
            Task {
                await self?.fetchDrivingLicence()
            }
        }
    }
}
