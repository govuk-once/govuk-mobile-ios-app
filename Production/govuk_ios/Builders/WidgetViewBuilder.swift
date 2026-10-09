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
        deviceInfo: DeviceInformationProviderInterface,
        versionProvider: AppVersionProvider,
        linkAction: @escaping () -> Void,
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
            linkAction: linkAction,
            dismissAction: dismissAction,
            editAction: editAction,
            openURLAction: openURLAction
        )
        let widget = TravelAlertsWidgetView(viewModel: viewModel)
        return AnyView(widget)
    }
}
