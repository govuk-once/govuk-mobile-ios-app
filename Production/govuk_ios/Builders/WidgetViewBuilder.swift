import SwiftUI
import GovKit

class WidgetViewBuilder {
    // swiftlint:disable:next function_parameter_count
    func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        linkAction: @escaping () -> Void,
        vehicleDetailAction: @escaping (Int) -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        let actions = DVLAAccountWidgetViewModel.Actions(
            linkAction: linkAction,
            vehicleDetailAction: vehicleDetailAction,
            openURLAction: openURLAction
        )
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

    func followCountryWidget(
        analyticsService: AnalyticsServiceInterface,
        travelService: TravelServiceInterface,
        linkAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void
    ) -> AnyView? {
        let viewModel = TravelTopicWidgetViewModel(
            travelService: travelService,
            linkAction: linkAction,
            dismissAction: dismissAction
        )
        let widget = TravelTopicWidgetView(viewModel: viewModel)
        return AnyView(widget)
    }
}
