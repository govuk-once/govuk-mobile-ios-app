import Foundation

protocol LicenceStatusViewModelBuilderInterface {
    func makeViewModel(
       status: DrivingLicenceStatus,
       validToDate: Date?,
       openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel
}

struct LicenceStatusViewModelBuilder: LicenceStatusViewModelBuilderInterface {
    private let expiringCountdownWindow: Int = 56 // days
    private let dateFormatter: DateFormatter = .dvlaAccount
    private let urls: DvlaURLs?

     init(urls: DvlaURLs?) {
         self.urls = urls
     }

    func makeViewModel(
        status: DrivingLicenceStatus,
        validToDate: Date?,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        makeViewModel(
            status: status,
            validToDate: validToDate,
            currentDate: Date(),
            openURLAction: openURLAction
        )
    }

     func makeViewModel(
        status: DrivingLicenceStatus,
        validToDate: Date?,
        currentDate: Date,
        openURLAction: @escaping (URL, String) -> Void
     ) -> ValidityStatusViewModel {
        switch status {
        case .expired:
            return makeExpiredViewModel(
                validToDate: validToDate,
                openURLAction: openURLAction
            )
        case .valid:
            if let validToDate = validToDate {
                let expiryProgress = ExpiryProgressCalculator.calculate(
                    expiryDate: validToDate,
                    countdownWindow: expiringCountdownWindow,
                    currentDate: currentDate
                )
                if expiryProgress.isWithinCountdownWindow {
                    return makeExpiringViewModel(
                        validToDate: validToDate,
                        expiryProgress: expiryProgress,
                        openURLAction: openURLAction
                    )
                }
            }
            return makeValidViewModel(validToDate: validToDate)
        default:
            return makeUnknownViewModel()
        }
    }

     private func formattedDate(_ date: Date?) -> String? {
         if let date = date {
             return dateFormatter.string(from: date)
         } else {
             return nil
         }
     }

    private func accessibilityLabel(for status: String) -> String {
        String(localized: .DVLA.licenceStatusAccessibilityLabel(status))
    }

     // MARK: - Expired
     private func makeExpiredViewModel(
         validToDate: Date?,
         openURLAction: @escaping (URL, String) -> Void
     ) -> ValidityStatusViewModel {
         let status: String
         if let dateString = formattedDate(validToDate) {
             status = String(localized: .DVLA.expiredOn(date: dateString))
         } else {
             status = String(localized: .DVLA.expired)
         }

         var buttonTitle: String?
         var buttonAction: (() -> Void)?
         if let renewURL = urls?.renewLicence {
             let title = String(localized: .DVLA.renewLicenceButtonTitle)
             buttonTitle = title
             buttonAction = {
                 openURLAction(renewURL, title)
             }
         }
         return ValidityStatusViewModel(
             status: status,
             statusAccessibilityLabel: accessibilityLabel(for: status),
             iconName: "exclamationmark.triangle.fill",
             footer: String(localized: .DVLA.licenceStatusFooter),
             buttonTitle: buttonTitle,
             buttonAction: buttonAction
         )
     }

     // MARK: - Valid
     private func makeValidViewModel(
        validToDate: Date?
     ) -> ValidityStatusViewModel {
         let status: String
         if let dateString = formattedDate(validToDate) {
             status = String(localized: .DVLA.validUntil(date: dateString))
         } else {
             status = String(localized: .DVLA.valid)
         }
         return ValidityStatusViewModel(
             status: status,
             statusAccessibilityLabel: accessibilityLabel(for: status),
             iconName: "checkmark.circle.fill",
             iconTintColour: .govUK.fills.surfaceButtonPrimary
         )
     }

    private func makeExpiringViewModel(
        validToDate: Date,
        expiryProgress: ExpiryProgressState,
        openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        let status = String(
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
        if let renewURL = urls?.renewLicence {
            let title = String(localized: .DVLA.renewLicenceButtonTitle)
            buttonTitle = title
            buttonAction = {
                openURLAction(renewURL, title)
            }
        }
        return ValidityStatusViewModel(
            status: status,
            statusAccessibilityLabel: accessibilityLabel(for: status),
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.licenceStatusFooter),
            buttonTitle: buttonTitle,
            buttonAction: buttonAction
        )
    }

    // MARK: - Unknown
    private func makeUnknownViewModel() -> ValidityStatusViewModel {
        let status = String(localized: .DVLA.unknown)
        return ValidityStatusViewModel(
            status: status,
            statusAccessibilityLabel: accessibilityLabel(for: status)
        )
    }
 }
