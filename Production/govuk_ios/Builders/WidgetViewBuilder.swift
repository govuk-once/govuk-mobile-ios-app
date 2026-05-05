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
        viewLicenceAction: @escaping () -> Void,
        viewDriverSummaryAction: @escaping () -> Void,
        viewCustomerSummaryAction: @escaping () -> Void
    ) -> AnyView? {
        let actions = DVLAAccountWidgetViewModel.Actions(
            linkAction: linkAction,
            unlinkAction: unlinkAction,
            viewLicenceAction: viewLicenceAction,
            viewDriverSummaryAction: viewDriverSummaryAction,
            viewCustomerSummaryAction: viewCustomerSummaryAction
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
