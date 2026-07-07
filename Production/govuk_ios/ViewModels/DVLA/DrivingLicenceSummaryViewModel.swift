import Foundation
import UIKit
import GovKit

struct DrivingLicenceSummaryViewModel {
    let licenceType: String
    let licenceNumber: String
    let fullName: String
    let address: [String]
    let licenceStatusViewModel: ValidityStatusViewModel
    let openURLAction: (URL, String) -> Void
    let menuSelectionAction: (URL) -> Void
    let analyticsService: AnalyticsServiceInterface

    let copyLicenceButtonTitle = String.dvla.localized(
        "copyLicenceButtonTitle"
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
    let changeAddressMenuTitle: String =  String.dvla.localized(
        "changeAddressMenuTitle"
    )
    let changeNameAndGender: String = String.dvla.localized(
        "changeNameAndGenderMenuTitle"
    )
    let replaceLicenceMenuTitle: String = String.dvla.localized(
        "replaceLicenceMenuTitle"
    )

    func openUrl(options: URLOptions) {
        menuSelectionAction(options.urlAndTitle.0)
        trackNavigation(text: options.urlAndTitle.1)
    }

    func copyToClipbaord() {
        UIPasteboard.general.string = licenceNumber
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

    private func trackNavigation(text: String) {
        let event = AppEvent.navigation(
            text: text,
            type: "Menu",
            external: true
        )
        analyticsService.track(event: event)
    }

    enum URLOptions {
        case changeAddresss
        case replaceLicence
        case changeNameAndGender

        var urlAndTitle: (URL, String) {
            switch self {
            case .changeAddresss:
                return (
                    Constants.API.dvlaChangeAddressUrl, String.dvla.localized(
                    "changeAddressMenuTitle"
                    )
                )
            case .replaceLicence:
                return (
                    Constants.API.dvlaReplaceDrivingLicence, String.dvla.localized(
                    "replaceLicenceMenuTitle"
                )
            )
            case .changeNameAndGender:
                return (
                    Constants.API.dvlaChangeAddressUrl, String.dvla.localized(
                    "changeNameAndGenderMenuTitle"
                    )
                )
            }
        }
    }
}

extension DrivingLicenceSummaryViewModel {
    init(
        driverSummary: DriverSummary,
        statusBuilder: LicenceStatusViewModelBuilderInterface,
        openURLAction: @escaping (URL, String) -> Void,
        menuSelectionAction: @escaping (URL) -> Void,
        analyticsService: AnalyticsServiceInterface
    ) {
        let licenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            driverSummary.response.licence.type
        )
        self.licenceType = licenceType
        self.openURLAction = openURLAction
        self.analyticsService = analyticsService
        self.menuSelectionAction = menuSelectionAction

        self.licenceNumber = driverSummary.response.driver.licenceNo
        let fullName = [
            driverSummary.response.driver.title,
            driverSummary.response.driver.firstNames,
            driverSummary.response.driver.lastName
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        self.fullName = fullName
        let driverAddress = driverSummary.response.driver.address.unstructuredAddress
        let addressArray = [
            driverAddress.line1?.capitalized,
            driverAddress.line2?.capitalized,
            driverAddress.line3?.capitalized,
            driverAddress.line4?.capitalized,
            driverAddress.line5?.capitalized,
            driverAddress.postcode
        ]
        .compactMap { $0 }
        self.address = addressArray
        self.licenceStatusViewModel = statusBuilder.makeViewModel(
            status: driverSummary.response.licence.status,
            validToDate: driverSummary.response.token?.validToDate,
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
        let address = addressArray.joined(separator: ", ")
        self.addressAccessibilityLabel = .localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            address
        )
    }
    func arrange(
        title: String = "MR",
        firstNames: String = "KENNETH",
        lastName: String = "DECERQUEIRA",
        address: DriverAddress,
        licenceNo: String = "DECER607085K99AE",
        licenceType: String = "Full",
        licenceStatus: DrivingLicenceStatus = .valid,
        penaltyPoints: Int = 1,
        validFrom: Date = .init(timeIntervalSince1970: 0),
        validTo: Date = .init(timeIntervalSince1970: 30)
    ) -> DriverSummary {
        .init(
            response: .init(
                driver: .init(
                    licenceNo: licenceNo,
                    title: title,
                    firstNames: firstNames,
                    lastName: lastName,
                    penaltyPoints: penaltyPoints,
                    address: address
                ),
                licence: .init(
                    type: licenceType,
                    status: licenceStatus
                ),
                token: .init(
                    validFromDate: validFrom,
                    validToDate: validTo
                )
            )
        )
    }

    func arrangeAdresss(
        line1: String? = "75 ST JOHN'S STREET",
        line2: String? = "GATESHEAD",
        line3: String? = nil,
        line4: String? = nil,
        line5: String? = nil,
        postcode: String? = "NE8 2ED"
    ) -> DriverAddress {
        .init(
            unstructuredAddress: .init(
                line1: line1,
                line2: line2,
                line3: line3,
                line4: line4,
                line5: line5,
                postcode: postcode
            )
        )
    }
}
