import Foundation

struct DrivingLicenceSummaryViewModel {
    let licenceType: String
    let licenceNumber: String
    let fullName: String
    let address: String
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
}

extension DrivingLicenceSummaryViewModel {
    init(
        drivingLicence: DrivingLicence,
        statusBuilder: LicenceStatusViewModelBuilderInterface,
        openURLAction: @escaping (URL, String) -> Void
    ) {
        let licenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            drivingLicence.licenceType
        )
        self.licenceType = licenceType

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
