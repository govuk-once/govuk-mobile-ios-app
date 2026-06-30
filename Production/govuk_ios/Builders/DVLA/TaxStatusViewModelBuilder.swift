import Foundation

import GovKit

protocol TaxStatusViewModelBuilderInterface {
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

    func makeViewModel(
        vehicle: CustomerSummary.Vehicle,
        openURLAction: @escaping (URL, String) -> Void
     ) -> ValidityStatusViewModel {
         switch vehicle.taxStatus {
         case .untaxed:
             return makeExpiredViewModel(
                status: vehicle.taxStatus,
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
                        status: vehicle.taxStatus,
                        validToDate: validToDate,
                        expiryProgress: expiryProgress,
                        openURLAction: openURLAction
                    )
                }
            }
            return makeValidViewModel(
                status: vehicle.taxStatus,
                validToDate: vehicle.taxedUntil
            )
         case .sorn:
             return makeSornViewModel(
                status: vehicle.taxStatus,
                fromDate: vehicle.sornStart
             )
         case .notTaxedForOnRoadUse:
             return makeTaxNotNeededViewModel(
                status: vehicle.taxStatus
             )
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

    // MARK: - Expiring
    private func makeExpiringViewModel(
        status: TaxStatus,
        validToDate: Date,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let formattedStatus = String(
            localized: .DVLA.expiringOn(
                date: formattedDate(validToDate) ?? ""
            )
        )
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft
        )
        var buttonTitle: String?
        var buttonAction: (() -> Void)?
        if let renewURL = urls?.taxVehicle {
            let title = String(localized: .DVLA.renewTaxButtonTitle)
            buttonTitle = title
            buttonAction = {
                openURLAction(renewURL, title)
            }
        }
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            formattedStatus: formattedStatus,
            status: status,
            progressViewModel: progressViewModel,
            buttonTitle: buttonTitle,
            buttonAction: buttonAction
        )
    }

    // MARK: - Unknown
    private func makeNotKnownViewModel(
        status: CustomerSummary.Vehicle
    ) -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            formattedStatus: String(localized: .DVLA.taxStatusTitle),
            status: status
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
 }
