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
    func makeViewModel(vehicle: MotStatusVehicle) -> ValidityStatusViewModel
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
        vehicle: MotStatusVehicle
    ) -> ValidityStatusViewModel {
        switch vehicle.motStatus {
        case "No results returned":
            return makeNoResultsViewModel()

        case "No details held by DVLA":
            return makeNoDetailsViewModel(vehicle: vehicle)

        case "Not valid":
            return makeExpiredViewModel(
                validToDate: vehicle.motExpiryDate
            )

        case "Valid":
            if let validToDate = vehicle.motExpiryDate {
                let expiryProgress = expiryProgressCalculator.calculate(
                    expiryDate: validToDate,
                    currentDate: Date.now
                )
                if expiryProgress.isExpired {
                    return makeExpiredViewModel(
                        validToDate: validToDate
                    )
                }
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

    private func makeExpiredViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus = if let dateString = formattedDate(validToDate) {
            String(localized: .DVLA.motExpiredOn(dateString))
        } else {
            String(localized: .DVLA.expired)
        }

        let statusInformation = StatusInformation(
            title: formattedStatus,
            accessibilityLabel: nil,
            linkAction: nil
        )

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            status: MOTValidityStatus.expired,
            statusInformation: statusInformation,
            iconName: "exclamationmark.triangle.fill"
        )
    }

    private func makeValidViewModel(
        validToDate: Date?
    ) -> ValidityStatusViewModel {
        let formattedStatus = if let dateString = formattedDate(validToDate) {
            String(localized: .DVLA.motValidUntil(dateString))
        } else {
            String(localized: .DVLA.valid)
        }

        let statusInformation = StatusInformation(
            title: formattedStatus,
            accessibilityLabel: nil,
            linkAction: nil)

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            status: MOTValidityStatus.valid,
            statusInformation: statusInformation,
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

        let formattedStatus = String(
            localized: .DVLA.motExpiringOn(
                formattedDate(validToDate) ?? "")
        )

        let statusInformation = StatusInformation(
            title: formattedStatus,
            accessibilityLabel: nil,
            linkAction: nil)

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            status: MOTValidityStatus.expiringSoon,
            statusInformation: statusInformation,
            progressViewModel: progressViewModel,
            footer: String(localized: .DVLA.motSyncDelayNotice)
        )
    }

    private func makeNotKnownViewModel() -> ValidityStatusViewModel {
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            status: MOTValidityStatus.unknown,
            statusInformation: StatusInformation(
                title: String(localized: .DVLA.motUnknown),
                accessibilityLabel: nil,
                linkAction: nil),
        )
    }

    private func makeNoResultsViewModel() -> ValidityStatusViewModel {
        let statusLinkTitle = String(localized: .DVLA.motCheckIfItNeedsAnMOT)
        let statusLinkActionURL = Constants.API.defaultDvlaNoResultsUrl

        let statusLinkAction = {
            openURLAction(statusLinkActionURL)
            trackUrlOpenEvent(url: statusLinkActionURL, text: statusLinkTitle)
        }

        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            status: MOTValidityStatus.noResultsReturned,
            statusInformation: StatusInformation(
                title: statusLinkTitle,
                accessibilityLabel: nil,
                linkAction: statusLinkAction)
        )
    }

    private func makeNoDetailsViewModel(
        vehicle: MotStatusVehicle
    ) -> ValidityStatusViewModel {
        let title = String(localized: .DVLA.motSeeStatusOnTheWebsite)
        var statusLinkActionURL = URL(string: Constants.API.defaultDvlaNoDetailsBaseUrlString)!

        if let baseUrl = URL(string: Constants.API.defaultDvlaNoDetailsBaseUrlString),
           var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) {
            components.queryItems = [
                URLQueryItem(name: "registration", value: vehicle.registrationNumber),
                URLQueryItem(name: "checkRecalls", value: "true")
            ]
            if let completedUrl = components.url {
                statusLinkActionURL = completedUrl
            }
        }

        let statusLinkAction = {
            openURLAction(statusLinkActionURL)
            trackUrlOpenEvent(url: statusLinkActionURL, text: title)
        }
        return ValidityStatusViewModel(
            title: String(localized: .DVLA.motStatusTitle),
            status: MOTValidityStatus.noDetailsHeldByDVLA,
            statusInformation: StatusInformation(
                title: title,
                accessibilityLabel: nil,
                linkAction: statusLinkAction)
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

struct MotStatusVehicle {
    let motStatus: String
    let motExpiryDate: Date?
    let registrationNumber: String
}
