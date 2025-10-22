//
//  AppDelegate.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let supportedOrientation: UIInterfaceOrientationMask = [.portrait]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureGlobalStyling()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        supportedOrientation
    }

    private func configureGlobalStyling() {
        let accent = UIColor(red: 0.18, green: 0.24, blue: 0.29, alpha: 0.95)
        let foreground = UIColor(red: 0.98, green: 0.91, blue: 0.74, alpha: 1.0)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = accent
        appearance.titleTextAttributes = [
            .foregroundColor: foreground,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = .white
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
