import SwiftUI
import Observation

public struct PrayerCheckRecord: Identifiable, Codable, Sendable {
    public var id: String { kind.rawValue }
    public let kind: PrayerKind
    public let timeString: String
    public var isCompleted: Bool
    public var detailText: String
}

@MainActor
@Observable
public final class PrayerViewModel {
    public var locationTitle: String = "Riyadh, Saudi Arabia"
    public var calendarName: String = "Umm Al-Qura (Makkah)"
    public var solarAngleText: String = "-18.5°"
    public var iqamahText: String = "Iqamah in 20 mins"
    public var adhanReciter: String = "Nasser Al-Qatami"
    public var countdownString: String = "01:26:14"
    public var weeklyComplianceRate: Int = 94
    public var qiblaDegrees: Double = 243.0
    public var currentDeviceHeading: Double = 0.0
    
    public var prayerRecords: [PrayerCheckRecord] = [
        PrayerCheckRecord(kind: .fajr, timeString: "04:48 AM", isCompleted: false, detailText: "Upcoming • Adhan Alert Active"),
        PrayerCheckRecord(kind: .sunrise, timeString: "06:05 AM", isCompleted: false, detailText: "Solar Disc Sunrise"),
        PrayerCheckRecord(kind: .dhuhr, timeString: "12:02 PM", isCompleted: true, detailText: "Congregation • 2 Sunnah Rak'ahs"),
        PrayerCheckRecord(kind: .asr, timeString: "03:28 PM", isCompleted: true, detailText: "Completed On Time"),
        PrayerCheckRecord(kind: .maghrib, timeString: "05:59 PM", isCompleted: true, detailText: "Iftar Time • Congregation"),
        PrayerCheckRecord(kind: .isha, timeString: "07:29 PM", isCompleted: true, detailText: "Completed with Imam • Taraweeh 11 Rak'ahs")
    ]
    
    public var completedCount: Int {
        prayerRecords.filter { $0.kind.isObligatoryPrayer && $0.isCompleted }.count
    }
    
    public var totalObligatoryCount: Int {
        prayerRecords.filter { $0.kind.isObligatoryPrayer }.count
    }
    
    public func togglePrayerCompletion(kind: PrayerKind) {
        if let idx = prayerRecords.firstIndex(where: { $0.kind == kind }) {
            prayerRecords[idx].isCompleted.toggle()
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }
    }
    
    public func updateHeading(_ heading: Double) {
        self.currentDeviceHeading = heading
    }
}
