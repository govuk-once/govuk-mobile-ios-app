import Foundation
import XCTest
import UIKit
import GovKit
import Combine

@testable import govuk_ios

@MainActor
class SettingsViewControllerSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() async {
        let mockVersionProvider = MockAppVersionProvider()
        mockVersionProvider.versionNumber = "1.2.3"
        mockVersionProvider.buildNumber = "123"
        let notificationService = MockNotificationService()
        notificationService._stubbedIsFetureEnabled = false
        let authenticationService = MockAuthenticationService()
        authenticationService._stubbedIsSignedIn = true
        authenticationService._stubbedUserEmail = "test@example.com"

        let viewModel = SettingsViewModel(
            analyticsService: MockAnalyticsService(),
            urlOpener: MockURLOpener(),
            versionProvider: mockVersionProvider,
            deviceInformationProvider: MockDeviceInformationProvider(),
            authenticationService: authenticationService,
            notificationService: notificationService,
            notificationCenter: .default,
            localAuthenticationService: MockLocalAuthenticationService(),
            appConfigService: MockAppConfigService()
        )
        let settingsContentView = SettingsView(
            viewModel: viewModel
        )
        let hostingViewController =  HostingViewController(
            rootView: settingsContentView,
            statusBarStyle: .darkContent
        )

        var cancellables = Set<AnyCancellable>()
        viewModel.updateEmail()
        await withCheckedContinuation { continuation in
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { _ in
                    self.VerifySnapshotInNavigationController(
                        viewController: hostingViewController,
                        mode: .light,
                        prefersLargeTitles: true
                    )
                    continuation.resume()
                    cancellables.removeAll()
                })
                .store(in: &cancellables)
        }
    }

    func test_loadInNavigationController_dark_rendersCorrectly() async {
        let mockVersionProvider = MockAppVersionProvider()
        mockVersionProvider.versionNumber = "1.2.3"
        mockVersionProvider.buildNumber = "123"
        let notificationService = MockNotificationService()
        notificationService._stubbedIsFetureEnabled = false
        let authenticationService = MockAuthenticationService()
        authenticationService._stubbedIsSignedIn = true
        authenticationService._stubbedUserEmail = "test@example.com"


        let viewModel = SettingsViewModel(
            analyticsService: MockAnalyticsService(),
            urlOpener: MockURLOpener(),
            versionProvider: mockVersionProvider,
            deviceInformationProvider: MockDeviceInformationProvider(),
            authenticationService: authenticationService,
            notificationService: notificationService,
            notificationCenter: .default,
            localAuthenticationService: MockLocalAuthenticationService(),
            appConfigService: MockAppConfigService()
        )
        let settingsContentView = SettingsView(
            viewModel: viewModel
        )
        let hostingViewController =  HostingViewController(
            rootView: settingsContentView,
            statusBarStyle: .darkContent
        )

        var cancellables = Set<AnyCancellable>()
        viewModel.updateEmail()
        await withCheckedContinuation { continuation in
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { _ in
                    self.VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
        // This is here to meet code coverage requirements
        viewModel.scrollToTop = true
                    continuation.resume()
                    cancellables.removeAll()
                })
                .store(in: &cancellables)
        }
    }

    func test_loadInNavigationController_notificationsFeatureEnabled_light_rendersCorrectly() async {
        let mockVersionProvider = MockAppVersionProvider()
        mockVersionProvider.versionNumber = "1.2.3"
        mockVersionProvider.buildNumber = "123"
        let notificationService = MockNotificationService()
        notificationService._stubbedIsFetureEnabled = true
        let authenticationService = MockAuthenticationService()
        authenticationService._stubbedIsSignedIn = true
        authenticationService._stubbedUserEmail = "test@example.com"

        let viewModel = SettingsViewModel(
            analyticsService: MockAnalyticsService(),
            urlOpener: MockURLOpener(),
            versionProvider: mockVersionProvider,
            deviceInformationProvider: MockDeviceInformationProvider(),
            authenticationService: authenticationService,
            notificationService: notificationService,
            notificationCenter: .default,
            localAuthenticationService: MockLocalAuthenticationService(),
            appConfigService: MockAppConfigService()
        )
        let settingsContentView = SettingsView(
            viewModel: viewModel
        )
        let hostingViewController =  HostingViewController(
            rootView: settingsContentView,
            statusBarStyle: .darkContent
        )

        var cancellables = Set<AnyCancellable>()
        viewModel.updateEmail()
        await withCheckedContinuation { continuation in
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { _ in
                    self.VerifySnapshotInNavigationController(
                        viewController: hostingViewController,
                        mode: .light,
                        prefersLargeTitles: true
                    )
                    continuation.resume()
                    cancellables.removeAll()
                })
                .store(in: &cancellables)
        }
    }

    func test_loadInNavigationController_notificationsFeatureEnabled_dark_rendersCorrectly() async {
        let mockVersionProvider = MockAppVersionProvider()
        mockVersionProvider.versionNumber = "1.2.3"
        mockVersionProvider.buildNumber = "123"
        let notificationService = MockNotificationService()
        notificationService._stubbedIsFetureEnabled = true
        let authenticationService = MockAuthenticationService()
        authenticationService._stubbedIsSignedIn = true
        authenticationService._stubbedUserEmail = "test@example.com"

        let viewModel = SettingsViewModel(
            analyticsService: MockAnalyticsService(),
            urlOpener: MockURLOpener(),
            versionProvider: mockVersionProvider,
            deviceInformationProvider: MockDeviceInformationProvider(),
            authenticationService: authenticationService,
            notificationService: notificationService,
            notificationCenter: .default,
            localAuthenticationService: MockLocalAuthenticationService(),
            appConfigService: MockAppConfigService()
        )
        
        let settingsContentView = SettingsView(
            viewModel: viewModel
        )
        let hostingViewController =  HostingViewController(
            rootView: settingsContentView,
            statusBarStyle: .darkContent
        )

        var cancellables = Set<AnyCancellable>()
        viewModel.updateEmail()
        await withCheckedContinuation { continuation in
            viewModel.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { _ in
                    self.VerifySnapshotInNavigationController(
                        viewController: hostingViewController,
                        mode: .dark,
                        prefersLargeTitles: true
                    )
                    continuation.resume()
                    cancellables.removeAll()
                })
                .store(in: &cancellables)
        }
    }

    func test_loadInNavigationController_preview_rendersCorrectly() {
        let settingsContentView = SettingsView(
            viewModel: GroupedListViewModel()
        )
        let viewController = HostingViewController(rootView: settingsContentView)
        viewController.title = "Settings"
        viewController.navigationItem.largeTitleDisplayMode = .always
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }
}

class GroupedListViewModel: SettingsViewModelInterface {
    var yourAccountsAction: (() -> Void)?
    var localAuthenticationAction: (() -> Void)?
    func updateNotificationPermissionState() {}
    var notificationsAction: (() -> Void)?
    var displayNotificationSettingsAlert: Bool = false
    func handleNotificationAlertAction() { }
    var notificationSettingsAlertTitle: String = "Turn on notifications"
    var notificationSettingsAlertBody: String = "Continue to your phone’s notifications settings to turn off notifications from GOV.UK"
    var notificationAlertButtonTitle: String = "Continue"
    var title: String = "Settings"
    var scrollToTop: Bool = false
    func trackScreen(screen: any TrackableScreen) {
        // Do Nothing
    }
    var signoutAction: (() -> Void)?
    var openAction: ((SettingsViewModelURLParameters) -> Void)?
    var sarAction: (() -> Void)?
    func updateEmail() {
    }
    var listContent: [GroupedListSection] {
        [
            .init(
                heading: GroupedListHeader(title: "Section 1",
                                           icon: nil,
                                           actionTitle: "See all",
                                           action: { print("tap") }),
                rows: [
                    InformationRow(
                        id: UUID().uuidString,
                        title: "Information row",
                        body: "Description",
                        detail: "0.0.1"
                    ),
                    LinkRow(
                        id: UUID().uuidString,
                        title: "Link row",
                        body: "A really long description to test how multiline text wrapping works",
                        action: {
                            print("link row tapped")
                        }
                    ),
                    LinkRow(
                        id: UUID().uuidString,
                        title: "Link row with leading icon",
                        body: nil,
                        imageName: "step_by_step",
                        showLinkImage: false,
                        action: {
                            print("link row tapped")
                        }
                    ),
                    NavigationRow(
                        id: UUID().uuidString,
                        title: "Nav row",
                        body: "Description",
                        action: {
                            print("nav row tapped")
                        }
                    ),
                    ToggleRow(
                        id: UUID().uuidString,
                        title: "Toggle",
                        isOn: false,
                        action: { isOn in
                            print("Toggled: \(isOn)")
                        }
                    ),
                    CountRow(
                        id: UUID().uuidString,
                        title: "Count",
                        state: .idle(showIndicator: true, count: 42),
                        action: {
                            print("Count row tapped")
                        }
                    ),
                    CountRow(
                        id: UUID().uuidString,
                        title: "Count loading",
                        state: .loading,
                        action: {
                            print("Count row tapped")
                        }
                    )
                ],
                footer: "some really important text about this section that is long enough to wrap"
            ),
            .init(
                heading: nil,
                rows: [
                    InformationRow(
                        id: UUID().uuidString,
                        title: "Information row",
                        body: "Description",
                        detail: "1.0"
                    ),
                    LinkRow(
                        id: UUID().uuidString,
                        title: "External link row",
                        body: nil,
                        action: {
                            print("link row tapped")
                        }
                    ),
                    NavigationRow(
                        id: UUID().uuidString,
                        title: "Navigation row",
                        body: "Description",
                        action: {
                            print("nav row tapped")
                        }
                    )
                ],
                footer: nil
            )
        ]
    }
}

class SettingsViewModelTester: ObservableObject {
    @Published var settingsViewModel: SettingsViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        observe()
    }

    private func observe() {
        settingsViewModel.objectWillChange
            .sink(receiveValue: objectWillChange.send)
            .store(in: &self.cancellables)
    }
}
