import SwiftUI
import GovKit

class WidgetViewBuilder {
    // swiftlint:disable:next function_parameter_count
    func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        linkAction: @escaping () -> Void,
        unlinkAction: @escaping () -> Void,
        vehicleDetailTappedAction: @escaping (CustomerSummary.Vehicle) -> Void,
        viewVehicleAction: @escaping () -> Void,
        viewShareCodesAction: @escaping () -> Void,
        createShareCodeAction: @escaping () -> Void
    ) -> AnyView? {
        let actions = DVLAAccountWidgetViewModel.Actions(
            linkAction: linkAction,
            unlinkAction: unlinkAction,
            vehicleDetailTappedAction: vehicleDetailTappedAction,
            viewVehicleAction: viewVehicleAction,
            viewShareCodesAction: viewShareCodesAction,
            createShareCodeAction: createShareCodeAction
        )
        let viewModel = DVLAAccountWidgetViewModel(
            analyticsService: analyticsService,
            userService: userService,
            dvlaService: dvlaService,
            actions: actions
        )
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        return AnyView(view)
    }
}
