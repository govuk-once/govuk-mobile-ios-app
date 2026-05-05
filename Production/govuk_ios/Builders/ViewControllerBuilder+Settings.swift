import SwiftUI
import GovKit

@MainActor
extension ViewControllerBuilder {
    func settings<T: SettingsViewModelInterface>(viewModel: T) -> UIViewController {
        let settingsContentView = SettingsView(
            viewModel: viewModel
        )

        let viewController = HostingViewController(
            rootView: settingsContentView,
            statusBarStyle: .darkContent
        )
        viewController.title = viewModel.title

        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }

    func faceIdSettings(
        analyticsService: AnalyticsServiceInterface,
        authenticationService: AuthenticationServiceInterface,
        localAuthenticationService: LocalAuthenticationServiceInterface,
        urlOpener: URLOpener
    ) -> UIViewController {
        let viewModel = LocalAuthenticationSettingsViewModel(
            authenticationService: authenticationService,
            localAuthenticationService: localAuthenticationService,
            analyticsService: analyticsService,
            urlOpener: urlOpener
        )
        let localAuthenticationSettingsView = FaceIdSettingsView(
            viewModel: viewModel
        )

        let viewController = HostingViewController(
            rootView: localAuthenticationSettingsView,
            statusBarStyle: .darkContent
        )
        viewController.title = viewModel.title

        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }

    func touchIdSettings(
        analyticsService: AnalyticsServiceInterface,
        authenticationService: AuthenticationServiceInterface,
        localAuthenticationService: LocalAuthenticationServiceInterface,
        urlOpener: URLOpener
    ) -> UIViewController {
        let viewModel = LocalAuthenticationSettingsViewModel(
            authenticationService: authenticationService,
            localAuthenticationService: localAuthenticationService,
            analyticsService: analyticsService,
            urlOpener: urlOpener
        )
        let touchIdSettingsView = TouchIdSettingsView(
            viewModel: viewModel
        )

        let viewController = HostingViewController(
            rootView: touchIdSettingsView,
            statusBarStyle: .darkContent
        )
        viewController.title = viewModel.title

        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }

    func notificationSettings(analyticsService: AnalyticsServiceInterface,
                              completeAction: @escaping () -> Void,
                              dismissAction: @escaping () -> Void,
                              viewPrivacyAction: @escaping () -> Void) -> UIViewController {
        let viewModel = NotificationsOnboardingViewModel(
            analyticsService: analyticsService,
            showImage: false,
            completeAction: completeAction,
            dismissAction: dismissAction,
            viewPrivacyAction: viewPrivacyAction
        )
        let view = NotificationsOnboardingView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(rootView: view)
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
}
