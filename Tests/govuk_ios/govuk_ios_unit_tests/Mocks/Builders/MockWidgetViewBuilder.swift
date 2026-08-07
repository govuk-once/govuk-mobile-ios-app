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
        linkAction: @escaping () -> Void,
        vehicleDetailAction: @escaping (Int) -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        _receivedDvlaAccountWidgetLinkAction = linkAction
        _receivedVehicleDetailAction = vehicleDetailAction
        return AnyView(EmptyView())
    }
}
