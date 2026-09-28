import SwiftUI

@main
struct IslamicCompanionApp: App {
    private let environment = AppEnvironment.shared
    
    init() {
        // Request initial location permissions gracefully upon launch
        environment.locationService.requestPermission()
        
        // Request notification authorization and schedule default daily adhkar reminders
        Task { @MainActor in
            let granted = await environment.notificationService.requestAuthorization()
            if granted {
                environment.notificationService.scheduleDailyAdhkarReminders()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark) // Aetherial Astrolabe OLED design language
        }
    }
}
