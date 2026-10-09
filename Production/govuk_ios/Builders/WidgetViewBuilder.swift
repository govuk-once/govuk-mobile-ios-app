import SwiftUI
import GovKit

class WidgetViewBuilder {
    func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        actions: DVLAAccountWidgetActions
    ) -> AnyView? {
        let viewModel = DVLAAccountWidgetViewModel(
            analyticsService: analyticsService,
            userService: userService,
            dvlaService: dvlaService,
            configService: configService,
            notificationCenter: .default,
            actions: actions
        )
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        return AnyView(view)
    }

    // swiftlint:disable:next function_parameter_count
    func travelAlertWidget(
        analyticsService: AnalyticsServiceInterface,
        travelService: TravelServiceInterface,
        notificationService: NotificationServiceInterface,
        linkAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void,
        editAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        let viewModel = TravelAlertsWidgetViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            urlOpener: UIApplication.shared,
            linkAction: linkAction,
            dismissAction: dismissAction,
            editAction: editAction,
            openURLAction: openURLAction
        )
        let widget = TravelAlertsWidgetView(viewModel: viewModel)
        return AnyView(widget)
    }
}
