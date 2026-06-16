import SwiftUI
import GovKit

@testable import govuk_ios

class MockWidgetViewBuilder: WidgetViewBuilder {
    var _receivedDvlaAccountWidgetLinkAction: (() -> Void)?
    var _receivedVehicleDetailTappedAction: ((CustomerSummary.Vehicle) -> Void)?
    var _receivedDvlaAccountWidgetUnlinkAction: (() -> Void)?
    var _receivedDvlaAccountWidgetViewShareCodesAction: (() -> Void)?
    override func dvlaAccountWidget(
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
        _receivedDvlaAccountWidgetLinkAction = linkAction
        _receivedDvlaAccountWidgetUnlinkAction = unlinkAction
        _receivedDvlaAccountWidgetViewShareCodesAction = viewShareCodesAction
        _receivedVehicleDetailTappedAction = vehicleDetailTappedAction
        return AnyView(EmptyView())
    }
}
