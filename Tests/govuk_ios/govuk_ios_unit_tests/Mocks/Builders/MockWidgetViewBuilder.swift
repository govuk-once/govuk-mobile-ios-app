import SwiftUI
import GovKit

@testable import govuk_ios

class MockWidgetViewBuilder: WidgetViewBuilder {
    var _receivedDvlaAccountWidgetLinkAction: (() -> Void)?
    var _receivedVehicleDetailAction: ((CustomerSummary.Vehicle) -> Void)?
    var _receivedDvlaAccountWidgetUnlinkAction: (() -> Void)?
    var _receivedDvlaAccountWidgetViewShareCodesAction: (() -> Void)?
    override func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        linkAction: @escaping () -> Void,
        unlinkAction: @escaping () -> Void,
        vehicleDetailAction: @escaping (CustomerSummary.Vehicle) -> Void,
        viewVehicleAction: @escaping () -> Void,
        viewShareCodesAction: @escaping () -> Void,
        createShareCodeAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        _receivedDvlaAccountWidgetLinkAction = linkAction
        _receivedDvlaAccountWidgetUnlinkAction = unlinkAction
        _receivedDvlaAccountWidgetViewShareCodesAction = viewShareCodesAction
        _receivedVehicleDetailAction = vehicleDetailAction
        return AnyView(EmptyView())
    }
}
