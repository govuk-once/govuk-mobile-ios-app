import Foundation
import GovKit
import GovKitUI

enum MOTValidityStatus: ValidityStatus {
    case valid
    case expiringSoon
    case expired
    case unknown
    case noResultsReturned
    case noDetailsHeldByDVLA
}

protocol MOTStatusViewModelBuilderInterface {
    @MainActor
    func makeViewModel(
        vehicle: CustomerSummary.Vehicle
    ) -> ValidityStatusViewModel
}

struct MOTStatusViewModelBuilder: MOTStatusViewModelBuilderInterface {
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
        vehicle: CustomerSummary.Vehicle
    ) -> ValidityStatusViewModel {
        // Handle explicit string status error responses first
        if vehicle.motStatus == "No results returned" {
            return makeNoResultsViewModel()
        }
        if vehicle.motStatus == "No details held by DVLA" {
            return makeNoDetailsViewModel()
        }

        let status = motValidityStatus(vehicle: vehicle)
        switch status {
        case .expired:
            return makeExpiredViewModel(
                validToDate: vehicle.motExpiryDate
            )
        case .valid:
            if let validToDate = vehicle.motExpiryDate {
                let expiryProgress = expiryProgressCalculator.calculate(
                    expiryDate: validToDate,
                    currentDate: Date.now
                )
                if expiryProgress.isWithinCountdownWindow {
                    return makeExpiringViewModel(
                        validToDate: validToDate,
                        expiryProgress: expiryProgress
                    )
                }
            }
            return makeValidViewModel(
                validToDate: vehicle.motExpiryDate
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

    // Core evaluator mapping the raw string statuses into domain cases
    private func motValidityStatus(vehicle: CustomerSummary.Vehicle) -> MOTValidityStatus {
        if vehicle.motStatus == "Not valid" {
            return .expired
        }
        if vehicle.motStatus == "Valid" {
            return .valid
        }
        return .unknown
    }

    // MARK: - Expired
    private func makeExpiredViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus: String
        if let dateString = formattedDate(validToDate) {
            formattedStatus = String(localized: "motExpiredOn \(dateString)")
        } else {
            formattedStatus = String(localized: "motExpired")
        }

        return ValidityStatusViewModel(
            title: String(localized: "motStatusTitle"),
            formattedStatus: formattedStatus,
            status: MOTValidityStatus.expired,
            iconName: "exclamationmark.triangle.fill"
        )
    }

    // MARK: - Valid
    private func makeValidViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus: String
        if let dateString = formattedDate(validToDate) {
            formattedStatus = String(localized: "motValidUntil \(dateString)")
        } else {
            formattedStatus = String(localized: "motValid")
        }

        return ValidityStatusViewModel(
            title: String(localized: "motStatusTitle"),
            formattedStatus: formattedStatus,
            status: MOTValidityStatus.valid,
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
        )
    }

    @MainActor
    // MARK: - Expiring
    private func makeExpiringViewModel(
        validToDate: Date,
        expiryProgress: ExpiryProgressState
    ) -> ValidityStatusViewModel {
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft
        )

        return ValidityStatusViewModel(
            title: String(localized: "motStatusTitle"),
            formattedStatus: String(
                localized: "motExpiringOn \(formattedDate(validToDate) ?? "")"
            ),
            status: MOTValidityStatus.expiringSoon,
            progressViewModel: progressViewModel,
            footer: String(localized: "motSyncDelayNotice")
        )
    }

    // MARK: - Unknown
    private func makeNotKnownViewModel() -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            title: String(localized: "motStatusTitle"),
            formattedStatus: String(localized: "motUnknown"),
            status: MOTValidityStatus.unknown
        )
    }

    // MARK: - Edge Case: No results returned
    private func makeNoResultsViewModel() -> ValidityStatusViewModel {
        let buttonTitle = String(localized: "motCheckDetailsLink")
        let buttonURL = urls?.motHelp ?? Constants.API.defaultDvlaNoResultsUrl

        return ValidityStatusViewModel(
            title: String(localized: "motStatusTitle"),
            formattedStatus: String(localized: "motNoResultsReturned"),
            status: MOTValidityStatus.noResultsReturned,
            buttonTitle: buttonTitle,
            buttonAction: {
                openURLAction(buttonURL) // Fixed parameter argument label issue
                trackUrlOpenEvent(url: buttonURL, text: buttonTitle)
            }
        )
    }

    // MARK: - Edge Case: No details held
    private func makeNoDetailsViewModel() -> ValidityStatusViewModel {
        let buttonTitle = String(localized: "motCheckDetailsLink")
        let buttonURL = urls?.motHelp ?? Constants.API.defaultDvlaNoDetailsUrl

        return ValidityStatusViewModel(
            title: String(localized: "motStatusTitle"),
            formattedStatus: String(localized: "motNoDetailsHeldByDVLA"),
            status: MOTValidityStatus.noDetailsHeldByDVLA,
            buttonTitle: buttonTitle,
            buttonAction: {
                openURLAction(buttonURL) // Fixed parameter argument label issue
                trackUrlOpenEvent(url: buttonURL, text: buttonTitle)
            }
        )
    }

    // MARK: - Analytics
    private func trackUrlOpenEvent(url: URL, text: String) {
        let event = AppEvent.buttonNavigation(
            text: text,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }
}
