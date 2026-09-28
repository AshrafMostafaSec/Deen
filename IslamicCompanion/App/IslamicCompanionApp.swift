import SwiftUI

@main
struct IslamicCompanionApp: App {
    private let environment = AppEnvironment.shared
    
    init() {
        // Request initial location permissions gracefully upon launch
        environment.locationService.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark) // Aetherial Astrolabe OLED design language
        }
    }
}
