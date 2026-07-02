import Foundation

import GovKit
import GovKitUI

protocol TaxStatusViewModelBuilderInterface {
    @MainActor
    func makeViewModel(
        vehicle: CustomerSummary.Vehicle,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel
}

struct TaxStatusViewModelBuilder: TaxStatusViewModelBuilderInterface {
    private let dateFormatter = DateFormatter.dvlaAccount
    private let expiryProgressCalculator = ExpiryProgressCalculator.init(countdownWindowDays: 28)
    private let urls: DvlaURLs?

    init(urls: DvlaURLs?) {
        self.urls = urls
    }

    @MainActor
    func makeViewModel(
        vehicle: CustomerSummary.Vehicle,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let status = validityTaxStatus(vehicle: vehicle)
        switch status {
        case .untaxed:
            return makeExpiredViewModel(
                validToDate: vehicle.taxedUntil,
                openURLAction: openURLAction
            )
        case .taxed:
            if let validToDate = vehicle.taxedUntil {
                let expiryProgress = expiryProgressCalculator.calculate(
                    expiryDate: validToDate,
                    currentDate: Date.now
                )
                if expiryProgress.isWithinCountdownWindow {
                    return makeExpiringViewModel(
                        validToDate: validToDate,
                        paymentMethod: vehicle.currentLicence?.paymentMethod ?? "",
                        expiryProgress: expiryProgress,
                        openURLAction: openURLAction
                    )
                }
            }
            return makeValidViewModel(
                validToDate: vehicle.taxedUntil
            )
        case .sorn:
            return makeSornViewModel(
                status: status,
                fromDate: vehicle.sornStart
            )
        case .futureSorn:
            return makeFutureSornViewModel(
                status: status
            )
        case .notTaxedForOnRoadUse:
            return makeTaxNotNeededViewModel()
        default:
            return makeNotKnownViewModel()
        }
    }

    private func formattedDate(_ date: Date?) -> String? {
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }

    // MARK: - Expired
    private func makeExpiredViewModel(
        validToDate: Date?,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let formattedStatus: String
        if let dateString = formattedDate(validToDate) {
            formattedStatus = String(localized: .DVLA.expiredOn(date: dateString))
        } else {
            formattedStatus = String(localized: .DVLA.expired)
        }

        let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
        let buttonAction = {
            openURLAction(
                (urls?.taxVehicle ?? Constants.API.defaultDvlaTaxVehicleUrl),
                buttonTitle
            )
        }
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: formattedStatus,
            iconName: "exclamationmark.triangle.fill",
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: buttonAction
        )
    }

    // MARK: - Valid
    private func makeValidViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus: String
        if let dateString = formattedDate(validToDate) {
            formattedStatus = String(localized: .DVLA.validUntil(date: dateString))
        } else {
            formattedStatus = String(localized: .DVLA.valid)
        }
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: formattedStatus,
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
        )
    }

    @MainActor
    // MARK: - Expiring
    private func makeExpiringViewModel(
        validToDate: Date,
        paymentMethod: String,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        if paymentMethod == "Direct Debit" {
            return makeExpiringDirectDebitViewModel(
                validToDate: validToDate,
                paymentMethod: paymentMethod,
                expiryProgress: expiryProgress,
                openURLAction: openURLAction
            )
        } else {
            return makeExpiringRenewTaxViewModel(
                validToDate: validToDate,
                expiryProgress: expiryProgress,
                openURLAction: openURLAction
            )
        }
    }

    // MARK: - Unknown
    private func makeNotKnownViewModel() -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: String(localized: .DVLA.unknown)
        )
    }

    // MARK: - Sorn
    private func makeSornViewModel(
        status: ValidityTaxStatus,
        fromDate: Date?
    ) -> ValidityStatusViewModel {
        var footer: String?
        if let dateString = formattedDate(fromDate) {
            footer = String(localized: .DVLA.from(date: dateString))
        }
        return ValidityStatusViewModel(
            formattedStatus: String(localized: .DVLA.offTheRoadSorn),
            status: status,
            iconName: "parkingsign.brakesignal",
            footer: footer
        )
    }

    // MARK: - Future sorn
    private func makeFutureSornViewModel(
        status: ValidityTaxStatus
    ) -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            formattedStatus: String(localized: .DVLA.offTheRoadSorn),
            status: status,
            iconName: "parkingsign.brakesignal"
        )
    }

    // MARK: - Not needed
    private func makeTaxNotNeededViewModel() -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: String(localized: .DVLA.vehicleTaxNotNeeded)
        )
    }

    @MainActor
    private func makeExpiringDirectDebitViewModel(
        validToDate: Date,
        paymentMethod: String,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.expiringTaxManagePaymentButtonTitle)
        let buttonURL = urls?.manageTaxPayment ?? Constants.API.defaultDvlaManageTaxPaymentUrl
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft,
            footer: String(localized: .DVLA.expiringTaxDirectDebit)
        )
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: String(
                localized: .DVLA.renewsOn(date: formattedDate(validToDate) ?? "")
            ),
            progressViewModel: progressViewModel,
            buttonTitle: buttonTitle,
            buttonAction: { openURLAction(buttonURL, buttonTitle) },
            buttonConfiguration: .groupedSecondary
        )
    }

    @MainActor
    private func makeExpiringRenewTaxViewModel(
        validToDate: Date,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
        let buttonURL = urls?.taxVehicle ?? Constants.API.defaultDvlaTaxVehicleUrl
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft
        )
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: String(
                localized: .DVLA.expiringOn(date: formattedDate(validToDate) ?? "")
            ),
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: { openURLAction(buttonURL, buttonTitle) },
            buttonConfiguration: .primary
        )
    }

    private func validityTaxStatus(
        vehicle: CustomerSummary.Vehicle
    ) -> ValidityTaxStatus {
        switch (vehicle.taxStatus, vehicle.sornStart) {
        case (.notTaxedForOnRoadUse, _):
            return .notTaxedForOnRoadUse
        case (.sorn, _):
            return .sorn
        case (.taxed, .some):
            return .futureSorn
        case (.untaxed, _):
            return .untaxed
        case (.taxed, _):
            return .taxed
        case (.none, _):
            return .unknown
        }
    }
}

enum ValidityTaxStatus: ValidityStatus {
    case notTaxedForOnRoadUse
    case sorn
    case futureSorn
    case untaxed
    case taxed
    case unknown
}
