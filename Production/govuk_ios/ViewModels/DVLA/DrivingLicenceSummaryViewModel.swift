import Foundation
import UIKit
import GovKit

struct DrivingLicenceSummaryViewModel {
    let licenceType: String
    let licenceNumber: String
    let fullName: String
    let address: String
    let licenceStatusViewModel: ValidityStatusViewModel
    private let pasteboard: PasteboardInterface

    let copyToClipboardButtonTitle = String.chat.localized(
        "copyToClipboardTitle"
    )
    let moreOptionsButtonAccessibilityLabel = String.dvla.localized(
        "moreOptionsButtonAccessibilityLabel"
    )
    let licenceNumberAccessibilityLabelPrefix = String.dvla.localized(
        "licenceNumberAccessibilityLabel"
    )
    let fullNameAccessibilityLabel: String
    let licenceTypeAccessibilityLabel: String
    let addressAccessibilityLabel: String
    var copyToClipboardAction: ((String) -> Void)
    let menuSelectionAction: (URL) -> Void
    let analyticsService: AnalyticsServiceInterface
    let copyLicenceButtonTitle = String.dvla.localized(
        "copyLicenceButtonTitle"
    )
    let changeAddressAccessibilityLabel = String.dvla.localized(
        "changeAddressAccessibilityLabel"
    )
    let changeNameOrGenderAccessibilityLabel = String.dvla.localized(
        "changeNameOrGenderAccessibilityLabel"
    )
    let changeAddressMenuTitle: String =  String.dvla.localized(
        "changeAddressMenuTitle"
    )
    let changeNameAndGender: String = String.dvla.localized(
        "changeNameAndGenderMenuTitle"
    )
    let replaceLicenceMenuTitle: String = String.dvla.localized(
        "replaceLicenceMenuTitle"
    )

    let configService: AppConfigServiceInterface

    func openUrl(options: URLOptions) {
        let urlAndTrackingTitle = options.urlAndTitle(using: configService)
        menuSelectionAction(
            urlAndTrackingTitle.0
        )
        trackNavigation(
            url: urlAndTrackingTitle.0,
            text: urlAndTrackingTitle.1
        )
    }

    func copyToClipboard() {
        pasteboard.string = licenceNumber
        trackCopyToClipboard()
    }

    private func trackCopyToClipboard() {
        let event = AppEvent.function(
            text: "Copy to clipboard",
            type: "Menu",
            section: "Driver account",
            action: "Copy"
        )
        analyticsService.track(event: event)
    }

    private func trackNavigation(url: URL, text: String) {
        let event = AppEvent.navigation(
            text: text,
            type: "Menu",
            external: true,
            additionalParams: ["url": url.absoluteString]
        )
        analyticsService.track(event: event)
    }

    enum URLOptions {
        case changeAddress
        case replaceLicence
        case changeNameAndGender

        func urlAndTitle(using configService: AppConfigServiceInterface)
        -> (URL, String) {
            switch self {
            case .changeAddress:
                return (configService.dvlaUrls?.changeLicenceAddress ??
                    Constants.API.defaultDvlaChangeAddressUrl, String.dvla.localized(
                        "changeAddressMenuTitle"
                    )
                )
            case .replaceLicence:
                return (configService.dvlaUrls?.replaceLicence ??
                    Constants.API.defaultDvlaReplaceDrivingLicence, String.dvla.localized(
                        "replaceLicenceMenuTitle"
                    )
                )
            case .changeNameAndGender:
                return (configService.dvlaUrls?.changeNameGenderLicence ??
                    Constants.API.defaultDvlaChangeNameAndGenderLicence, String.dvla.localized(
                        "changeNameAndGenderMenuTitle"
                    )
                )
            }
        }
    }
}

extension DrivingLicenceSummaryViewModel {
    init(
        drivingLicence: DrivingLicence,
        statusBuilder: LicenceStatusViewModelBuilderInterface,
        openURLAction: @escaping (URL, String) -> Void,
        menuSelectionAction: @escaping (URL) -> Void,
        copyToClipboardAction: @escaping (String) -> Void,
        analyticsService: AnalyticsServiceInterface,
        pasteboard: PasteboardInterface = UIPasteboard.general,
        configService: AppConfigServiceInterface
    ) {
        let licenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            drivingLicence.licenceType
        )
        self.licenceType = licenceType
        self.analyticsService = analyticsService
        self.menuSelectionAction = menuSelectionAction
        self.copyToClipboardAction = copyToClipboardAction
        self.pasteboard = pasteboard
        self.configService = configService

        self.licenceNumber = drivingLicence.licenceNumber
        let fullName = [
            drivingLicence.driverTitle,
            drivingLicence.driverFirstNames,
            drivingLicence.driverLastName
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        self.fullName = fullName
        let driverAddress = drivingLicence.driverFullAddress ?? ""
        self.address = driverAddress
        self.licenceStatusViewModel = statusBuilder.makeViewModel(
            status: drivingLicence.licenceStatus,
            validToDate: drivingLicence.tokenValidToDate,
            openURLAction: openURLAction
        )
        self.fullNameAccessibilityLabel = .localizedStringWithFormat(
            String.dvla.localized("licenceFullNameAccessibilityLabel"),
            fullName
        )
        self.licenceTypeAccessibilityLabel = .localizedStringWithFormat(
            String.dvla.localized("licenceTypeAccessibilityLabel"),
            licenceType
        )
        self.addressAccessibilityLabel = .localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            driverAddress.replacingOccurrences(of: "\n", with: ", ")
        )
    }
}
