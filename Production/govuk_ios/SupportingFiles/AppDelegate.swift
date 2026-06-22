import UIKit
import GovKit
import GovKitUI

class AppDelegate: UIResponder,
                   UIApplicationDelegate {
    @Inject(\.analyticsService) private var analyticsService: AnalyticsServiceInterface
    @Inject(\.notificationService) private var notificationService: NotificationServiceInterface

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureGlobalAppearance()
        analyticsService.launch()
        notificationService.appDidFinishLaunching(launchOptions: launchOptions)
        UINavigationBar.appearance().tintColor = .govUK.text.linkSecondary
        return true
    }

    private func configureGlobalAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.titleTextAttributes = [
            .font: UIFont.govUK.bodySemibold
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .font: UIFont.govUK.largeTitleBold
        ]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        sceneConfiguration.storyboard = nil

        return sceneConfiguration
    }
}
