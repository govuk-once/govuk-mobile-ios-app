import Foundation

import GOVKit

struct ChatWidgetViewModel {
    private let analyticsService: AnalyticsServiceInterface
    let id: String
    let title: String
    let body: String
    let linkUrl: URL
    let linkTitle: String
    let urlOpener: URLOpener
    let dismissAction: () -> Void

    init(analyticsService: AnalyticsServiceInterface,
         chat: ChatBanner,
         urlOpener: URLOpener,
         dismissAction: @escaping () -> Void) {
        id = chat.id
        title = chat.title
        body = chat.body
        linkUrl = chat.link.url
        linkTitle = chat.link.title
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.dismissAction = dismissAction
    }

    func open() {
        let event = AppEvent.widgetNavigation(text: title)
        analyticsService.track(event: event)
        urlOpener.openIfPossible(linkUrl)
    }

    func dismiss() {
        let analyticsText = title
        let event = AppEvent.buttonFunction(
            text: analyticsText,
            section: "Banner",
            action: "Dismiss")
        analyticsService.track(event: event)
        dismissAction()
    }
}
