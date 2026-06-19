import Foundation

protocol LicenceStatusViewModelBuilderInterface {
    func makeViewModel(
       status: DrivingLicenceStatus,
       validToDate: Date?,
       openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel
}

struct LicenceStatusViewModelBuilder: LicenceStatusViewModelBuilderInterface {
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
        switch status {
        case .expired:
            return makeExpiredViewModel(
                validToDate: validToDate,
                openURLAction: openURLAction
            )
        case .valid:
            return makeValidViewModel(validToDate: validToDate)
        default:
            return ValidityStatusViewModel(status: String(localized: .DVLA.unknown))
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
         let statusText: String
         if let dateString = formattedDate(validToDate) {
             statusText = String(localized: .DVLA.expiredOn(date: dateString))
         } else {
             statusText = String(localized: .DVLA.expired)
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
             status: statusText,
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
             iconName: "checkmark.circle.fill",
             iconTintColour: .govUK.fills.surfaceButtonPrimary
         )
     }
 }
