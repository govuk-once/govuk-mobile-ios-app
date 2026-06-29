import Foundation
import UIKit
import GovKit

struct QualtricsClient: AnalyticsClient {
    private let qualtricsService: QualtricsServiceInterface

    init(qualtricsService: QualtricsServiceInterface) {
        self.qualtricsService = qualtricsService
    }

    func track(screen: any TrackableScreen) {
        let params: [String: String] = [
            "screen_name": screen.trackingName,
            "screen_class": screen.trackingClass,
            "screen_title": screen.trackingTitle,
            "language": screen.trackingLanguage
        ]
            .compactMapValues({ $0 })
            .merging(
                screen.additionalParameters
                    .compactMapValues({ $0 as? String }),
                uniquingKeysWith: { param, _ in param }
            )
        Task {
            await qualtricsService.evaluateViewEvent(
                screenName: screen.trackingName,
                params: params
            )
        }
    }

    func track(event: GovKit.AppEvent) {
        guard !event.isEcommerceEvent else { return }
        let params: [String: String] = event.params?.compactMapValues( { $0 as? String }) ?? [:]
        Task {
            await qualtricsService.evaluateClickEvent(params: params)
        }
    }

    func launch() { /* Do nothing */ }

    func setEnabled(enabled: Bool) { /* Do nothing */ }

    func track(error: any Error) { /* Do nothing */ }

    func set(userProperty: GovKit.UserProperty) { /* Do nothing */ }
}
