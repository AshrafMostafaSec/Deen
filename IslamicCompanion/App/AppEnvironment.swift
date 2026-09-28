import SwiftUI

@MainActor
public final class AppEnvironment {
    public static let shared = AppEnvironment()
    
    public let audioService: AudioService
    public let locationService: LocationService
    public let prayerEngine: PrayerEngine
    
    public init(
        audioService: AudioService = AudioService.shared,
        locationService: LocationService = LocationService(),
        prayerEngine: PrayerEngine = PrayerEngine()
    ) {
        self.audioService = audioService
        self.locationService = locationService
        self.prayerEngine = prayerEngine
    }
}
