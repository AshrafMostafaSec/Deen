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
        locationService: LocationService = LocationService(),
        prayerEngine: PrayerEngine = PrayerEngine(),
        notificationService: NotificationService = NotificationService.shared
    ) {
        self.audioService = audioService
        self.locationService = locationService
        self.prayerEngine = prayerEngine
        self.notificationService = notificationService
    }
}

/// EnvironmentKey to inject LocationService into the SwiftUI environment
private struct LocationServiceKey: EnvironmentKey {
    static let defaultValue: LocationService? = nil
}

public extension EnvironmentValues {
    var locationService: LocationService {
        get { self[LocationServiceKey.self] ?? AppEnvironment.shared.locationService }
        set { self[LocationServiceKey.self] = newValue }
    }
}
