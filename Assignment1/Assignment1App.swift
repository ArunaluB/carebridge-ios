// Assignment1App.swift
// NurseryConnect
// Main app entry point with splash screen, onboarding, and environment setup

import SwiftUI

@main
struct Assignment1App: App {
    @State private var dataManager = DataManager.shared
    @State private var themeManager = ThemeManager()
    @State private var attendanceManager = AttendanceManager.shared
    @State private var messageManager = MessageManager.shared
    @State private var notificationManager = NotificationManager.shared
    @State private var sleepTrackerManager = SleepTrackerManager.shared
    @State private var splashFinished = false
    @State private var onboardingFinished: Bool
    
    init() {
        // Check if onboarding has been shown before
        let hasLaunched = UserDefaults.standard.bool(forKey: "nc_has_launched_before")
        _onboardingFinished = State(initialValue: hasLaunched)
        
        // Configure navigation bar appearance
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Force the navigation bar to match the ncBackground color in both light/dark modes
        appearance.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 26/255, green: 27/255, blue: 46/255, alpha: 1)  // 1A1B2E
                : UIColor(red: 250/255, green: 250/255, blue: 248/255, alpha: 1) // FAFAF8
        }
        appearance.shadowColor = .clear // Remove the bottom line

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
                } else if !onboardingFinished {
                    OnboardingView(isFinished: $onboardingFinished)
                        .transition(.opacity)
                        .onChange(of: onboardingFinished) { _, newValue in
                            if newValue {
                                UserDefaults.standard.set(true, forKey: "nc_has_launched_before")
                            }
                        }
                } else {
                    ContentView()
                        .environment(dataManager)
                        .environment(themeManager)
                        .environment(attendanceManager)
                        .environment(messageManager)
                        .environment(notificationManager)
                        .environment(sleepTrackerManager)
                        .preferredColorScheme(themeManager.colorScheme)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: splashFinished)
            .animation(.easeInOut(duration: 0.5), value: onboardingFinished)
        }
    }
}
