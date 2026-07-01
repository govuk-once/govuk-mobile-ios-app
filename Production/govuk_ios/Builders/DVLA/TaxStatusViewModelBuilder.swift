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
         switch vehicle.taxStatus {
         case .untaxed:
             return makeExpiredViewModel(
                status: .untaxed,
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
                        status: .taxed,
                        validToDate: validToDate,
                        paymentMethod: vehicle.currentLicence?.paymentMethod ?? "",
                        expiryProgress: expiryProgress,
                        openURLAction: openURLAction
                    )
                }
            }
            return makeValidViewModel(
                status: .taxed,
                validToDate: vehicle.taxedUntil
            )
         case .sorn:
             return makeSornViewModel(
                status: .sorn,
                fromDate: vehicle.sornStart
             )
         case .notTaxedForOnRoadUse:
             return makeTaxNotNeededViewModel(
                status: .notTaxedForOnRoadUse
             )
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
        status: TaxStatus,
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
            status: status,
            iconName: "exclamationmark.triangle.fill",
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: buttonAction
         )
     }

     // MARK: - Valid
     private func makeValidViewModel(
        status: TaxStatus,
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
            status: status,
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
         )
     }

    @MainActor
    // MARK: - Expiring
    private func makeExpiringViewModel(
        status: TaxStatus,
        validToDate: Date,
        paymentMethod: String,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        if paymentMethod == "Direct Debit" {
            return makeExpiringDirectDebitViewModel(
                status: status,
                validToDate: validToDate,
                paymentMethod: paymentMethod,
                expiryProgress: expiryProgress,
                openURLAction: openURLAction
            )
        } else {
            return makeExpiringRenewTaxViewModel(
                status: status,
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
        status: TaxStatus,
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

    // MARK: - Not needed
    private func makeTaxNotNeededViewModel(
        status: TaxStatus,
    ) -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: String(localized: .DVLA.vehicleTaxNotNeeded),
            status: status
        )
    }

    @MainActor
    private func makeExpiringDirectDebitViewModel(
        status: TaxStatus,
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
            status: status,
            progressViewModel: progressViewModel,
            buttonTitle: buttonTitle,
            buttonAction: { openURLAction(buttonURL, buttonTitle) },
            buttonConfiguration: .secondary
        )
    }

    @MainActor
    private func makeExpiringRenewTaxViewModel(
        status: TaxStatus,
        validToDate: Date,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
        let buttonURL = urls?.renewLicence ?? Constants.API.defaultDvlaTaxVehicleUrl
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft
        )
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: String(
                localized: .DVLA.expiringOn(date: formattedDate(validToDate) ?? "")
            ),
            status: status,
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: { openURLAction(buttonURL, buttonTitle) },
            buttonConfiguration: .primary
        )
    }
 }
