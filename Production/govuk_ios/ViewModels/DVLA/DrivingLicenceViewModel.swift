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
    private let configService: AppConfigServiceInterface
    private let openURLAction: (URL) -> Void

    init(viewState: ViewState = .loading,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         configService: AppConfigServiceInterface,
         openURLAction: @escaping (URL) -> Void) {
        self.viewState = viewState
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.openURLAction = openURLAction
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
            let licenceSummaryViewModel = DrivingLicenceSummaryViewModel(
                driverSummary: driverSummary,
                statusBuilder: LicenceStatusViewModelBuilder(urls: configService.dvlaUrls),
                openURLAction: { [weak self] url in
                    self?.openURLAction(url)
                }, analyticsService: analyticsService
            )
            hasLoadedLicence = true
            viewState = .loaded(licence: licenceSummaryViewModel)
        case .failure:
            viewState = .error(dvlaAccountErrorViewModel)
        }
    }


    func handleOpenURL(url: URL, buttonTitle: String) {
        trackOpenURLAction(url: url, buttonTitle: buttonTitle)
        openURLAction(url)
    }

    private func trackOpenURLAction(url: URL, buttonTitle: String) {
        let event = AppEvent.buttonNavigation(
            text: buttonTitle,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
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
