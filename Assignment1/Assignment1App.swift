// NurseryConnect main app entry and environment setup.

import SwiftUI

@main
struct Assignment1App: App {
    @State private var dataManager = DataManager.shared
    @State private var themeManager = ThemeManager()
    @State private var notificationManager = NotificationManager.shared
    @State private var sleepTrackerManager = SleepTrackerManager.shared
    @State private var splashFinished = false
    
    init() {
        // Configure a consistent navigation bar style for light/dark mode.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 26/255, green: 27/255, blue: 46/255, alpha: 1)  // 1A1B2E
                : UIColor(red: 250/255, green: 250/255, blue: 248/255, alpha: 1) // FAFAF8
        }
        appearance.shadowColor = .clear

        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !splashFinished {
                    SplashView(isFinished: $splashFinished)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environment(dataManager)
                        .environment(themeManager)
                        .environment(notificationManager)
                        .environment(sleepTrackerManager)
                        .preferredColorScheme(themeManager.colorScheme)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: splashFinished)
        }
    }
}
