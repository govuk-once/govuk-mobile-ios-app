import SwiftUI
import GovKit

class WidgetViewBuilder {
    func makeAccountWidget(
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
    func makeTravelAlertWidget(
        analyticsService: AnalyticsServiceInterface,
        travelService: TravelServiceInterface,
        notificationService: NotificationServiceInterface,
        deviceInfo: DeviceInformationProviderInterface,
        versionProvider: AppVersionProvider,
        dismissAction: @escaping () -> Void,
        editAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        let feedbackURL = deviceInfo.helpAndFeedbackURL(versionProvider: versionProvider)
        let viewModel = TravelAlertsWidgetViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            feedbackURL: feedbackURL,
            urlOpener: UIApplication.shared,
            dismissAction: dismissAction,
            editAction: editAction,
            openURLAction: openURLAction
        )
        let widget = TravelAlertsWidgetView(viewModel: viewModel)
        return AnyView(widget)
    }

    func makeDWPWidget(
        analyticsService: AnalyticsServiceInterface
    ) -> AnyView? {
        let viewModel = DWPWidgetViewModel(
            analyticsService: analyticsService
        )
        let widget = DWPWidgetView(viewModel: viewModel)
        return AnyView(widget)
    }
}
