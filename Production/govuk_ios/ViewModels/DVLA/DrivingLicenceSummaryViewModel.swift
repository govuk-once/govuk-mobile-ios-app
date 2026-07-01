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
    let fullNameAccessibilityLabel: String
    let licenceTypeAccessibilityLabel: String
    let addressAccessibilityLabel: String
    var copyToClipboardAction: ((String) -> Void)?

    func openUrl() {

    }

    func copyToClipboard(licenceNumber: String) {
        UIPasteboard.general.string = licenceNumber
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        trackCopyLicenceNumberToClipboard()
    }
}

extension DrivingLicenceSummaryViewModel {
    init(
        driverSummary: DriverSummary,
        statusBuilder: LicenceStatusViewModelBuilderInterface,
        openURLAction: @escaping (URL, String) -> Void
    ) {
        let licenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            driverSummary.response.licence.type
        )
        self.licenceType = licenceType

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
