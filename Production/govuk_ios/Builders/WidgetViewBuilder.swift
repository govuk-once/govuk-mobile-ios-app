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
        userService: UserServiceInterface,
        configService: AppConfigServiceInterface,
        linkAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void
    ) -> AnyView? {
        let widget = IconActionCardView(
            viewModel: IconActionCardViewModel(
                iconName: "plus.circle",
                title: String(localized: .Travel.followCountriesTitle),
                description: String(localized: .Travel.followCountriesDescription),
                action: linkAction,
                contentPadding: 24,
                iconBottomPadding: 16
            )
        )
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        return AnyView(widget)
    }
}
