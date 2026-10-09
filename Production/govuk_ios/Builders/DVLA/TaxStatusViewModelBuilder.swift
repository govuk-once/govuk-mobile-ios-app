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
        let status = TaxValidityStatus(
            taxStatus: vehicle.taxStatus,
            sornStartDate: vehicle.sornStart
        )
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

/// Represents the resolved road tax validity state for a vehicle, combining raw tax status and SORN scheduling data.
///
/// Use this type to determine UI displays, warning badges, or permission checks regarding whether a vehicle is legally taxed,
/// scheduled to go on [Statutory Off Road Notification (SORN)](https://www.gov.uk/make-a-sorn), or untaxed.
///
/// - Note: A Statutory Off Road Notification (SORN) informs the DVLA
///   that a vehicle is being taken off public roads and will not be driven or parked on them.
///
/// - Note: A state of ``futureSorn`` occurs when a vehicle is currently taxed but has a SORN start date registered for a future date.
enum TaxValidityStatus: ValidityStatus {
    /// The vehicle category or tax class is exempt from standard on-road tax requirements.
    case notTaxedForOnRoadUse

    /// The vehicle is registered under a [SORN](https://www.gov.uk/make-a-sorn) and cannot be legally driven on public roads.
    case sorn

    /// The vehicle is currently taxed, but a [SORN](https://www.gov.uk/make-a-sorn) is scheduled for a future date.
    case futureSorn

    /// The vehicle is untaxed and does not have an active SORN declaration.
    case untaxed

    /// The vehicle is currently taxed for road use with no upcoming SORN.
    case taxed

    // The tax validity status could not be determined due to missing or invalid data.
    case unknown

    init(taxStatus: TaxStatus?, sornStartDate: Date?) {
        guard let taxStatus else {
            self = .unknown
            return
        }

        switch (taxStatus, sornStartDate) {
        // 1. Currently Taxed states (active tax)
        case (.taxed, .some):
            self = .futureSorn
        case (.taxed, .none):
            self = .taxed
        // 2. SORN states (Off-road declaration)
        case (.sorn, _):
            self = .sorn
        // 3. Unregistered / Untaxed states
        case (.untaxed, _):
            self = .untaxed
        case (.notTaxedForOnRoadUse, _):
            self = .notTaxedForOnRoadUse
        }
    }
}

struct TaxValidityVehicle {
    let taxStatus: TaxStatus?
    let sornStart: Date?
    let taxedUntil: Date?
    let currentLicencePaymentMethod: String?
}
