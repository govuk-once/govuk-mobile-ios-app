import GovKit
import SwiftUI

class DrivingLicenceViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded(
            licence: DrivingLicenceSummaryViewModel,
            drivingRecord: DrivingRecordViewModel
        )
        case error(InlineActionErrorViewModel)
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
        let result = await dvlaService.fetchDrivingLicence()
        switch result {
        case .success(let drivingLicence):
            var licenceSummaryViewModel = DrivingLicenceSummaryViewModel(
                drivingLicence: drivingLicence,
                statusBuilder: LicenceStatusViewModelBuilder(urls: configService.dvlaUrls),
                openURLAction: { [weak self] url, buttonTitle in
                    self?.handleOpenURL(url: url, buttonTitle: buttonTitle)
                },
                menuSelectionAction: { [weak self] url in
                    self?.openURLAction(url)
                },
                copyToClipboardAction: { [weak self] licenceNumber in
                    self?.copyToClipboard(licenceNumber: licenceNumber
                    )
                },
                analyticsService: analyticsService
            )

            hasLoadedLicence = true

            let drivingRecordViewModel = DrivingRecordViewModel(
                dvlaURLs: configService.dvlaUrls,
                openURLAction: handleOpenURL(url:buttonTitle:)
            )

            viewState = .loaded(
                licence: licenceSummaryViewModel,
                drivingRecord: drivingRecordViewModel
            )
        case .failure:
            viewState = .error(drivingLicenceErrorViewModel)
        }
    }

    private func handleOpenURL(url: URL, buttonTitle: String) {
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

    private var drivingLicenceErrorViewModel: InlineActionErrorViewModel {
        let url = configService.dvlaUrls?.driverDetails ?? Constants.API.defaultDvlaDriverDetailsUrl
        let buttonTitle = String(localized: .DVLA.licenceSummaryErrorButtonTitle)
        let errorBody = String(
            localized: .DVLA.licenceSummaryErrorBody(
            buttonTitle: buttonTitle,
            url: url.absoluteString)
        )
        return InlineActionErrorViewModel(
            title: String(localized: .DVLA.licenceSummaryErrorTitle),
            markdownBody: errorBody,
            openURLAction: { [weak self] url in
                self?.handleOpenURL(url: url, buttonTitle: buttonTitle)
            }
        )
    }
}
