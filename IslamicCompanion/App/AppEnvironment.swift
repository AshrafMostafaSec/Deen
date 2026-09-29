import SwiftUI

@MainActor
public final class AppEnvironment {
    public static let shared = AppEnvironment()
    
    public let audioService: AudioService
    public let locationService: LocationService
    public let prayerEngine: PrayerEngine
    public let notificationService: NotificationService
    
    public init(
        audioService: AudioService = AudioService.shared,
        locationService: LocationService = LocationService.shared,
        prayerEngine: PrayerEngine = PrayerEngine(),
        notificationService: NotificationService = NotificationService.shared
    ) {
        self.audioService = audioService
        self.locationService = locationService
        self.prayerEngine = prayerEngine
        self.notificationService = notificationService
    }
}
