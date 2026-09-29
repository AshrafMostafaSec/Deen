import SwiftUI

@main
struct IslamicCompanionApp: App {
    init() {}
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark) // Aetherial Astrolabe OLED design language
                .task {
                    // Safe execution on MainActor after window tree is mounted
                    let environment = AppEnvironment.shared
                    
                    // Request location permission for prayer astronomical calculations
                    environment.locationService.requestPermission()
                    
                    // Request notification permission and schedule default reminders
                    let granted = await environment.notificationService.requestAuthorization()
                    if granted {
                        environment.notificationService.scheduleDailyAdhkarReminders()
                    }
                }
                .environment(\.locationService, AppEnvironment.shared.locationService)
        }
    }
}
