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
    var copyToClipboardAction: ((String) -> Void)?
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
        openURLAction(options.urlAndTitle.0, options.urlAndTitle.1)
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
                    "changeNameAndGenderMenuTitle"
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
    ) {
        let licenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            driverSummary.response.licence.type
        )
        self.licenceType = licenceType
        self.openURLAction = openURLAction

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
}
