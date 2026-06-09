import SwiftUI
import GovKit

@testable import govuk_ios

class MockWidgetViewBuilder: WidgetViewBuilder {
    var _receivedDvlaAccountWidgetLinkAction: (() -> Void)?
    var _receivedDvlaAccountWidgetUnlinkAction: (() -> Void)?
    var _receivedDvlaAccountWidgetViewShareCodesAction: (() -> Void)?
    override func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        linkAction: @escaping () -> Void,
        unlinkAction: @escaping () -> Void,
        viewDriverSummaryAction: @escaping () -> Void,
        viewCustomerSummaryAction: @escaping () -> Void,
        viewVehicleAction: @escaping () -> Void,
        viewShareCodesAction: @escaping () -> Void,
        createShareCodeAction: @escaping () -> Void
    ) -> AnyView? {
        _receivedDvlaAccountWidgetLinkAction = linkAction
        _receivedDvlaAccountWidgetUnlinkAction = unlinkAction
        _receivedDvlaAccountWidgetViewShareCodesAction = viewShareCodesAction
        return AnyView(EmptyView())
    }
}
