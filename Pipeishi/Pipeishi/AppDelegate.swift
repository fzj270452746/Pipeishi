

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applyGlobalNavigationBarTheme()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        allowedOrientations
//    }

    private func applyGlobalNavigationBarTheme() {
        let navigationBarColor = UIColor(red: 0.18, green: 0.24, blue: 0.29, alpha: 0.95)
        let textColor = UIColor(red: 0.98, green: 0.91, blue: 0.74, alpha: 1.0)

        let navigationBarStyling = UINavigationBarAppearance()
        navigationBarStyling.configureWithOpaqueBackground()
        navigationBarStyling.backgroundColor = navigationBarColor
        navigationBarStyling.titleTextAttributes = [
            .foregroundColor: textColor,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]

        let globalNavigationBar = UINavigationBar.appearance()
        globalNavigationBar.tintColor = .white
        globalNavigationBar.standardAppearance = navigationBarStyling
        globalNavigationBar.compactAppearance = navigationBarStyling
        globalNavigationBar.scrollEdgeAppearance = navigationBarStyling
    }
}
