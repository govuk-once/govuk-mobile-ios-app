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
        vehicleDetailAction: @escaping (CustomerSummary.Vehicle) -> Void,
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
            actions: actions
        )
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        return AnyView(view)
    }
}
