import SwiftUI
import GovKit

@testable import govuk_ios

class MockWidgetViewBuilder: WidgetViewBuilder {
    var _receivedDvlaAccountWidgetLinkAction: (() -> Void)?
    var _receivedVehicleDetailAction: ((Int) -> Void)?

    override func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        actions: DVLAAccountWidgetActions
    ) -> AnyView? {
        _receivedDvlaAccountWidgetLinkAction = actions.linkAction
        _receivedVehicleDetailAction = actions.vehicleDetailAction
        return AnyView(EmptyView())
    }

    var _receivedTravelAlertLinkAction: (() -> Void)?
    var _receivedTravelAlertDismissAction: (() -> Void)?
    var _receivedTravelAlertEditAction: (() -> Void)?
    var _receivedTravelAlertOpenURLAction: ((URL) -> Void)?

    override func travelAlertWidget(
        analyticsService: AnalyticsServiceInterface,
        travelService: TravelServiceInterface,
        notificationService: NotificationServiceInterface,
        deviceInfo: DeviceInformationProviderInterface,
        versionProvider: AppVersionProvider,
        linkAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void,
        editAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        _receivedTravelAlertLinkAction = linkAction
        _receivedTravelAlertDismissAction = dismissAction
        _receivedTravelAlertEditAction = editAction
        _receivedTravelAlertOpenURLAction = openURLAction
        return AnyView(EmptyView())
    }
}
