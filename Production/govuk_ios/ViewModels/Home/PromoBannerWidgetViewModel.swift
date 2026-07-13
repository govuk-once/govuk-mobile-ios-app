import Foundation

import GovKit

struct PromoBannerWidgetViewModel {
    private let analyticsService: AnalyticsServiceInterface
    let id: String
    let title: String
    let body: String
    let linkUrl: URL
    let linkTitle: String
    let imageTitle: String?
    let urlOpener: URLOpener
    let dismissAction: () -> Void

    init(analyticsService: AnalyticsServiceInterface,
         chatBanner: ChatBanner,
         urlOpener: URLOpener,
         dismissAction: @escaping () -> Void) {
        id = chatBanner.id
        title = chatBanner.title
        body = chatBanner.body
        linkUrl = chatBanner.link.url
        linkTitle = chatBanner.link.title
        imageTitle = "chat_widget"
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.dismissAction = dismissAction
    }

    init(analyticsService: AnalyticsServiceInterface,
         banner: PromoBanner,
         urlOpener: URLOpener,
         dismissAction: @escaping () -> Void) {
        id = banner.id
        title = banner.title
        body = banner.body
        linkUrl = banner.link.url
        linkTitle = banner.link.title
        imageTitle = nil
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
            action: "Dismiss"
        )
        analyticsService.track(event: event)
        dismissAction()
    }
}
