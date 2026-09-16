import Foundation

import GovKit
import GovKitUI

protocol TaxStatusViewModelBuilderInterface {
    @MainActor
    func makeViewModel(
        vehicle: TaxValidityVehicle,
    ) -> ValidityStatusViewModel
}

struct TaxStatusViewModelBuilder: TaxStatusViewModelBuilderInterface {
    private let dateFormatter = DateFormatter.dvlaAccount
    private let expiryProgressCalculator = ExpiryProgressCalculator.init(countdownWindowDays: 28)
    private let urls: DvlaURLs?
    private let analyticsService: AnalyticsServiceInterface
    private let openURLAction: (URL) -> Void

    init(
        urls: DvlaURLs?,
        analyticsService: AnalyticsServiceInterface,
        openURLAction: @escaping (URL) -> Void
    ) {
        self.urls = urls
        self.analyticsService = analyticsService
        self.openURLAction = openURLAction
    }

    @MainActor
    func makeViewModel(
        vehicle: TaxValidityVehicle
    ) -> ValidityStatusViewModel {
        let status = taxValidityStatus(vehicle: vehicle)
        switch status {
        case .untaxed:
            return makeExpiredViewModel()
        case .taxed:
            return makeViewModelForTaxed(vehicle: vehicle)
        case .sorn:
            return makeSornViewModel(
                status: status,
            )
        case .futureSorn:
            return makeFutureSornViewModel(
                status: status,
                fromDate: vehicle.sornStart
            )
        case .notTaxedForOnRoadUse:
            return makeTaxNotNeededViewModel()
        case .unknown:
            return makeNotKnownViewModel()
        }
    }

    // MARK: - Taxed
    @MainActor
    private func makeViewModelForTaxed(vehicle: TaxValidityVehicle) -> ValidityStatusViewModel {
        if let validToDate = vehicle.taxedUntil {
            let expiryProgress = expiryProgressCalculator.calculate(
                expiryDate: validToDate,
                currentDate: Date.now
            )
            if expiryProgress.isExpired {
                return makeExpiredViewModel()
            }
            if expiryProgress.isWithinCountdownWindow {
                return makeExpiringViewModel(
                    validToDate: validToDate,
                    paymentMethod: vehicle.currentLicencePaymentMethod ?? "",
                    expiryProgress: expiryProgress
                )
            }
        }
        return makeValidViewModel(
            validToDate: vehicle.taxedUntil
        )
    }

    // MARK: - Expired
    private func makeExpiredViewModel() -> ValidityStatusViewModel {
        let formattedStatus = String(localized: .DVLA.untaxed)
        let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
        let buttonURL = urls?.taxVehicle ?? Constants.API.defaultDvlaTaxVehicleUrl

        let statusInformation = StatusInformation(formattedStatus)

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            statusInformation: statusInformation,
            iconName: "exclamationmark.triangle.fill",
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: {
                openURLAction(
                    text: buttonTitle,
                    url: buttonURL
                )
            }
        )
    }

    // MARK: - Valid
    private func makeValidViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus = if let dateString = formattedDate(validToDate) {
            String(localized: .DVLA.validUntil(date: dateString))
        } else {
            String(localized: .DVLA.valid)
        }

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            statusInformation: StatusInformation(formattedStatus),
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
        )
    }

    @MainActor
    // MARK: - Expiring
    private func makeExpiringViewModel(
        validToDate: Date,
        paymentMethod: String,
        expiryProgress: ExpiryProgressState
    ) -> ValidityStatusViewModel {
        if paymentMethod == "Direct Debit" {
            return makeExpiringDirectDebitViewModel(
                validToDate: validToDate,
                expiryProgress: expiryProgress
            )
        } else {
            return makeExpiringRenewTaxViewModel(
                validToDate: validToDate,
                expiryProgress: expiryProgress
            )
        }
    }

    // MARK: - Unknown
    private func makeNotKnownViewModel() -> ValidityStatusViewModel {
        let statusLinkAction: (() -> Void)? = {
            let title = String(localized: .DVLA.notFoundContactDVLA)
            let contactURL = urls?.contact ?? Constants.API.defaultDvlaContactUrl
            openURLAction(text: title, url: contactURL)
        }

        let formattedStatus = String(localized: .DVLA.notFoundContactDVLA)

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            status: TaxValidityStatus.unknown,
            statusInformation: StatusInformation(formattedStatus,
                                                 linkAction: statusLinkAction)
        )
    }

    // MARK: - Sorn
    private func makeSornViewModel(
        status: TaxValidityStatus,
    ) -> ValidityStatusViewModel {
        let statusInformation = StatusInformation(String(localized: .DVLA.offTheRoadSorn))

        return ValidityStatusViewModel(
            status: status,
            statusInformation: statusInformation,
            iconName: "parkingsign.brakesignal"
        )
    }

    // MARK: - Future sorn
    private func makeFutureSornViewModel(
        status: TaxValidityStatus,
        fromDate: Date?
    ) -> ValidityStatusViewModel {
        var footer: String?
        if let dateString = formattedDate(fromDate) {
            footer = String(localized: .DVLA.from(date: dateString))
        }

        return ValidityStatusViewModel(
            status: status,
            statusInformation: StatusInformation(String(localized: .DVLA.offTheRoadSorn)),
            iconName: "parkingsign.brakesignal",
            footer: footer
        )
    }

    // MARK: - Not needed
    private func makeTaxNotNeededViewModel() -> ValidityStatusViewModel {
        let statusInformation = StatusInformation(
            String(localized: .DVLA.noTaxToPay)
        )

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            statusInformation: statusInformation,
        )
    }

    @MainActor
    private func makeExpiringDirectDebitViewModel(
        validToDate: Date,
        expiryProgress: ExpiryProgressState
    ) -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.expiringTaxManagePaymentButtonTitle)
        let buttonURL = urls?.manageTaxPayment ?? Constants.API.defaultDvlaManageTaxPaymentUrl
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft,
            footer: String(localized: .DVLA.expiringTaxDirectDebit)
        )
        let statusInformation = StatusInformation(
            String(
                localized: .DVLA.renewsOn(date: formattedDate(validToDate) ?? "")
            ),
        )

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            statusInformation: statusInformation,
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: { openURLAction(
                text: buttonTitle,
                url: buttonURL
            )},
            buttonConfiguration: .groupedSecondary
        )
    }

    @MainActor
    private func makeExpiringRenewTaxViewModel(
        validToDate: Date,
        expiryProgress: ExpiryProgressState
    ) -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
        let buttonURL = urls?.taxVehicle ?? Constants.API.defaultDvlaTaxVehicleUrl
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft
        )
        let statusInformation = StatusInformation(
            String(
                localized: .DVLA.expiringOn(date: formattedDate(validToDate) ?? "")
            ),
        )

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            statusInformation: statusInformation,
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.renewTaxExpiringFooter),
            buttonTitle: buttonTitle,
            buttonAction: { openURLAction(
                text: buttonTitle,
                url: buttonURL
            )},
            buttonConfiguration: .primary
        )
    }

    private func taxValidityStatus(
        vehicle: TaxValidityVehicle
    ) -> TaxValidityStatus {
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

// MARK: - Helper methods
extension TaxStatusViewModelBuilder {
    private func formattedDate(_ date: Date?) -> String? {
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }

    private func openURLAction(text: String, url: URL) {
        let event = AppEvent.buttonNavigation(
            text: text,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
        openURLAction(url)
    }
}

enum TaxValidityStatus: ValidityStatus {
    case notTaxedForOnRoadUse
    case sorn
    case futureSorn
    case untaxed
    case taxed
    case unknown
}

struct TaxValidityVehicle {
    let taxStatus: TaxStatus?
    let sornStart: Date?
    let taxedUntil: Date?
    let currentLicencePaymentMethod: String?
}
