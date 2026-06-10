import Foundation

struct DrivingLicenceSummaryViewModel {
    let licenceType: String
    let licenceNumber: String
    let fullName: String
    let address: [String]
    let licenceStatusViewModel: ValidityStatusViewModel

    let copyToClipboardButtonTitle = String.chat.localized(
        "copyToClipboardTitle"
    )
    let moreOptionsButtonAccessibilityLabel = String.dvla.localized(
        "moreOptionsButtonAccessibilityLabel"
    )
    let licenceNumberAccessibilityLabelPrefix = String.dvla.localized(
        "licenceNumberAccessibilityLabel"
    )
    let licenceTypeAccessibilityLabel: String
    let licenceStatusAccessibilityLabel: String
    let addressAccessibilityLabel: String
    var copyToClipboardAction: ((String) -> Void)?
}

extension DrivingLicenceSummaryViewModel {
    init(
        driverSummary: DriverSummary,
        statusFormatter: DVLAValidityStatusFormatter = DVLAValidityStatusFormatter()
    ) {
        let licenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            driverSummary.response.licence.type
        )
        self.licenceType = licenceType

        self.licenceNumber = driverSummary.response.driver.licenceNo
        self.fullName = [
            driverSummary.response.driver.title,
            driverSummary.response.driver.firstNames,
            driverSummary.response.driver.lastName
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        .capitalized
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

        let licenceStatus = statusFormatter.formatStatus(
            from: driverSummary.response.token.validToDate
        )
        self.licenceStatusViewModel = ValidityStatusViewModel(
            title: nil,
            status: licenceStatus
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
        self.licenceStatusAccessibilityLabel = .localizedStringWithFormat(
            String.dvla.localized("licenceStatusAccessibilityLabel"),
            licenceStatus
        )
    }
}
