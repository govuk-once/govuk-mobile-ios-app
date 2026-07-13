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

protocol MotStatusViewModelBuilderInterface {
    @MainActor
    func makeViewModel(
        vehicle: CustomerSummary.Vehicle
    ) -> ValidityStatusViewModel
}

struct MotStatusViewModelBuilder: MotStatusViewModelBuilderInterface {
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
        if vehicle.motStatus == "No results returned" {
            return makeNoResultsViewModel()
        }
        if vehicle.motStatus == "No details held by DVLA" {
            return makeNoDetailsViewModel(vehicle: vehicle)
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

    private func motValidityStatus(vehicle: CustomerSummary.Vehicle) -> MOTValidityStatus {
        if vehicle.motStatus == "Not valid" {
            return .expired
        }
        if vehicle.motStatus == "Valid" {
            return .valid
        }
        return .unknown
    }

    private func makeExpiredViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus: String
        if let dateString = formattedDate(validToDate) {
            formattedStatus = String(localized: .DVLA.motExpiredOn(dateString))
        } else {
            formattedStatus = String(localized: .DVLA.motStatusTitle)
        }

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            formattedStatus: formattedStatus,
            status: MOTValidityStatus.expired,
            iconName: "exclamationmark.triangle.fill"
        )
    }

    private func makeValidViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus: String
        if let dateString = formattedDate(validToDate) {
            formattedStatus =  String(localized: .DVLA.motValidUntil(dateString))
        } else {
            formattedStatus = String(localized: .DVLA.valid)
        }

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            formattedStatus: formattedStatus,
            status: MOTValidityStatus.valid,
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary
        )
    }

    @MainActor
    private func makeExpiringViewModel(
        validToDate: Date,
        expiryProgress: ExpiryProgressState
    ) -> ValidityStatusViewModel {
        let progressViewModel = ExpiryProgressViewModel(
            progress: expiryProgress.progress,
            daysLeft: expiryProgress.daysLeft
        )

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            formattedStatus: String(
                localized: .DVLA.motExpiringOn(
                    formattedDate(validToDate) ?? "")
            ),
            status: MOTValidityStatus.expiringSoon,
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.motSyncDelayNotice)
        )
    }

    private func makeNotKnownViewModel() -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            formattedStatus: String(localized: .DVLA.motUnknown),
            status: MOTValidityStatus.unknown
        )
    }

    private func makeNoResultsViewModel() -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.motCheckIfItNeedsAnMOT)
        let buttonURL = Constants.API.defaultDvlaNoResultsUrl

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            formattedStatus: String(localized: ""),
            status: MOTValidityStatus.noResultsReturned,
            buttonTitle: buttonTitle,
            buttonAction: {
                openURLAction(buttonURL)
                trackUrlOpenEvent(url: buttonURL, text: buttonTitle)
            }
        )
    }

    private func makeNoDetailsViewModel(
        vehicle: CustomerSummary.Vehicle
    ) -> ValidityStatusViewModel {
        let buttonTitle = String(localized: .DVLA.motSeeStatusOnTheWebsite)
        var buttonURL = URL(string: Constants.API.defaultDvlaNoDetailsBaseUrlString)!

        if let baseUrl = URL(string: Constants.API.defaultDvlaNoDetailsBaseUrlString),
           var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) {
            components.queryItems = [
                URLQueryItem(name: "registration", value: vehicle.registrationNumber),
                URLQueryItem(name: "checkRecalls", value: "true")
            ]
            if let completedUrl = components.url {
                buttonURL = completedUrl
            }
        }

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            formattedStatus: String(localized: ""),
            status: MOTValidityStatus.noDetailsHeldByDVLA,
            buttonTitle: buttonTitle,
            buttonAction: {
                openURLAction(buttonURL)
                trackUrlOpenEvent(url: buttonURL, text: buttonTitle)
            }
        )
    }

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
