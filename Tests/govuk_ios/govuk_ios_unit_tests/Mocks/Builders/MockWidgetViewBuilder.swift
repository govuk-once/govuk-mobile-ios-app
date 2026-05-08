import SwiftUI
import GovKit

@testable import govuk_ios

class MockWidgetViewBuilder: WidgetViewBuilder {
    var _receivedDvlaAccountWidgetLinkAction: (() -> Void)?
    var _receivedDvlaAccountWidgetUnlinkAction: (() -> Void)?
    var _receivedDvlaAccountWidgetViewLicenceAction: (() -> Void)?
    override func dvlaAccountWidget(
        analyticsService: AnalyticsServiceInterface,
        userService: UserServiceInterface,
        dvlaService: DVLAServiceInterface,
        linkAction: @escaping () -> Void,
        unlinkAction: @escaping () -> Void,
        viewLicenceAction: @escaping () -> Void,
        viewDriverSummaryAction: @escaping () -> Void,
        viewCustomerSummaryAction: @escaping () -> Void
    ) -> AnyView? {
        _receivedDvlaAccountWidgetLinkAction = linkAction
        _receivedDvlaAccountWidgetUnlinkAction = unlinkAction
        _receivedDvlaAccountWidgetViewLicenceAction = viewLicenceAction
        return AnyView(EmptyView())
    }
}
