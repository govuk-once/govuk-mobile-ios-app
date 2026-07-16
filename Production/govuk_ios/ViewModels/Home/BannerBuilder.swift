import Foundation
import GovKit

class BannerBuilder {
    private let userDefaultsService: UserDefaultsServiceInterface
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let urlOpener: URLOpener
    private let chatEnabled: Bool
    private let openURLAction: (URL) -> Void
    private let updateWidgetsAction: () -> Void

    private(set) var bannersECommerceItems = [HomeCommerceItem]()
    private let homeBannersListName: String = "home_banners"

    init(userDefaultsService: UserDefaultsServiceInterface,
         configService: AppConfigServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         urlOpener: URLOpener,
         chatEnabled: Bool,
         openURLAction: @escaping (URL) -> Void,
         updateWidgetsAction: @escaping () -> Void) {
        self.userDefaultsService = userDefaultsService
        self.configService = configService
        self.analyticsService = analyticsService
        self.chatEnabled = chatEnabled
        self.urlOpener = urlOpener
        self.openURLAction = openURLAction
        self.updateWidgetsAction = updateWidgetsAction
    }

    func bannerWidgets() -> [HomepageWidget] {
        bannersECommerceItems = []
        return emergencyBannersWidgets +
        promoBannerWidgets +
        chatBannerWidgets
    }

    private var emergencyBannersWidgets: [HomepageWidget] {
        guard let banners = configService.emergencyBanners
        else { return [] }

        let visibleBanners = banners.filter { !userDefaultsService.hasSeen(banner: $0) }

        return visibleBanners.enumerated().map { iterator in
            let ecommItem = iterator.element.asHomeCommerceItem(
                index: bannersECommerceItems.count + 1
            )
            bannersECommerceItems.append(ecommItem)
            let viewModel = EmergencyBannerWidgetViewModel(
                banner: iterator.element,
                analyticsService: analyticsService,
                sortPriority: (visibleBanners.count - iterator.offset),
                openURLAction: openURLAction,
                didSelectAction: { [weak self] in
                    self?.trackItemSelection(item: ecommItem)
                },
                dismissAction: { [weak self] in
                    self?.userDefaultsService.markSeen(banner: iterator.element)
                    self?.updateWidgetsAction()
                    self?.trackBannersEcommerceEvent()
                }
            )

            return HomepageWidget(
                content: EmergencyBannerWidgetView(
                    viewModel: viewModel
                )
            )
        }
    }

    private var promoBannerWidgets: [HomepageWidget] {
        guard let banners = configService.promoBanners
        else { return [] }

        let visibleBanners = banners.filter { !userDefaultsService.hasSeen(banner: $0) }

        return visibleBanners.compactMap {
            self.promoBannerWidget($0)
        }
    }

    private func promoBannerWidget(_ banner: PromoBanner) -> HomepageWidget {
        let ecommItem = banner.asHomeCommerceItem(
            listName: homeBannersListName,
            index: bannersECommerceItems.count + 1
        )
        bannersECommerceItems.append(ecommItem)

        let viewModel = PromoBannerWidgetViewModel(
            analyticsService: analyticsService,
            banner: banner,
            urlOpener: urlOpener,
            didSelectAction: { [weak self] in
                self?.trackItemSelection(item: ecommItem)
            },
            dismissAction: { [weak self] in
                self?.userDefaultsService.markSeen(banner: banner)
                self?.updateWidgetsAction()
                self?.trackBannersEcommerceEvent()
            }
        )

        return HomepageWidget(
            content: PromoBannerWidgetView(
                viewModel: viewModel
            )
        )
    }

    private var chatBannerWidgets: [HomepageWidget] {
        guard chatEnabled,
              let chatBanner = configService.chatBanner,
              !userDefaultsService.hasSeen(banner: chatBanner)
        else { return [] }

        let ecommItem = chatBanner.asHomeCommerceItem(
            listName: homeBannersListName,
            index: bannersECommerceItems.count + 1
        )
        bannersECommerceItems.append(ecommItem)

        let viewModel = PromoBannerWidgetViewModel(
            analyticsService: analyticsService,
            chatBanner: chatBanner,
            urlOpener: urlOpener,
            didSelectAction: { [weak self] in
                self?.trackItemSelection(item: ecommItem)
            },
            dismissAction: { [weak self] in
                self?.userDefaultsService.markSeen(banner: chatBanner)
                self?.updateWidgetsAction()
                self?.trackBannersEcommerceEvent()
            }
        )

        return [
            HomepageWidget(
                content: PromoBannerWidgetView(
                    viewModel: viewModel
                )
            )
        ]
    }

    func trackBannersEcommerceEvent() {
        let event = AppEvent.viewItemList(
            name: homeBannersListName,
            id: homeBannersListName,
            items: bannersECommerceItems
        )
        analyticsService.track(event: event)
    }

    private func trackItemSelection(item: HomeCommerceItem) {
        let event = AppEvent.selectBannerItem(
            itemName: item.name,
            index: item.index,
            results: bannersECommerceItems.count,
        )
        analyticsService.track(event: event)
    }
}
