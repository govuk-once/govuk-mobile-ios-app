import GovKit
import SwiftUI

class DrivingLicenceViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded(licence: DrivingLicenceSummaryViewModel)
        case error(AppErrorViewModel)
    }

    @Published private(set) var viewState: ViewState

    private var hasLoadedLicence = false
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface

    init(viewState: ViewState = .loading,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface) {
        self.viewState = viewState
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
    }

    @MainActor
    func viewDidAppear() async {
        if !hasLoadedLicence {
            await fetchLicence()
        }
    }

    func copyToClipboard(licenceNumber: String) {
        UIPasteboard.general.string = licenceNumber
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        trackCopyLicenceNumberToClipboard()
    }

    @MainActor
    private func fetchLicence() async {
        viewState = .loading
        let result = await dvlaService.fetchDriverSummary()
        switch result {
        case .success(let driverSummary):
            var licenceSummaryViewModel = DrivingLicenceSummaryViewModel(
                driverSummary: driverSummary
            )
            licenceSummaryViewModel.copyToClipboardAction = { [weak self] licenceNumber in
                self?.copyToClipboard(licenceNumber: licenceNumber)
            }
            hasLoadedLicence = true
            viewState = .loaded(licence: licenceSummaryViewModel)
        case .failure:
            viewState = .error(dvlaAccountErrorViewModel)
        }
    }

    private func trackCopyLicenceNumberToClipboard() {
        let event = AppEvent.buttonFunction(
            text: "Copy to clipboard",
            section: "Driving",
            action: "Copy"
        )
        analyticsService.track(event: event)
    }

    private var dvlaAccountErrorViewModel: AppErrorViewModel {
        .dvlaAccountErrorWithAction { [weak self] in
            Task {
                await self?.fetchLicence()
            }
        }
    }
}
