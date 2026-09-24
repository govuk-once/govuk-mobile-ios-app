import SwiftUI
import GovKit

@testable import govuk_ios

class MockWidgetViewBuilder: WidgetViewBuilder {
    var _receivedDvlaAccountWidgetLinkAction: (() -> Void)?
    var _receivedVehicleDetailAction: ((Int) -> Void)?
    override func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        actions: DVLAAccountWidgetActions
    ) -> AnyView? {
        _receivedDvlaAccountWidgetLinkAction = actions.linkAction
        _receivedVehicleDetailAction = actions.vehicleDetailAction
        return AnyView(EmptyView())
    }
}
