import SwiftUI
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    public var locationName: String = "Riyadh, Saudi Arabia"
    public var hijriDateString: String = "14 Ramadan 1447 AH • 22 March"
    public var greetingName: String = "Ahmed"
    
    public var prayerSchedule: PrayerSchedule
    public var countdownString: String = "01:26:14"
    public var qiyamTimeString: String = "02:37 AM"
    public var isQiyamAlarmEnabled: Bool = true
    
    // Quran Progress
    public var quranSurahName: String = "Surah Al-Baqarah"
    public var quranPage: Int = 28
    public var quranCompletedPages: Int = 3
    public var quranGoalPages: Int = 5
    
    // Adhkar Progress
    public var adhkarTitle: String = "Evening Adhkar"
    public var adhkarCompleted: Int = 12
    public var adhkarTotal: Int = 24
    
    // Daily Hadith
    public let dailyHadithText: String = "«أَحَبُّ الأَعْمَالِ إِلَى اللهِ أَدْوَمُهَا وَإِنْ قَلَّ»"
    public let dailyHadithSource: String = "Sahih Muslim"
    
    private let engine = PrayerEngine()
    private nonisolated(unsafe) var countdownTimer: Timer?
    private var remainingSeconds: Int = 5174
    
    public init() {
        self.prayerSchedule = engine.calculateSchedule(
            date: Date(),
            latitude: 24.7136,
            longitude: 46.6753,
            locationName: "Riyadh"
        )
        self.remainingSeconds = prayerSchedule.nextPrayerCountdownSeconds
        updateCountdownString()
        startTimer()
        updateRemindersAndQiyam()
    }
    
    public func updateLocation(latitude: Double, longitude: Double, name: String) {
        self.locationName = name
        self.prayerSchedule = engine.calculateSchedule(
            date: Date(),
            latitude: latitude,
            longitude: longitude,
            locationName: name
        )
        self.remainingSeconds = prayerSchedule.nextPrayerCountdownSeconds
        updateCountdownString()
        updateRemindersAndQiyam()
    }
    
    public func toggleQiyamAlarm() {
        isQiyamAlarmEnabled.toggle()
        updateRemindersAndQiyam()
    }
    
    private func updateRemindersAndQiyam() {
        NotificationService.shared.schedulePrayerReminders(schedule: prayerSchedule)
        if let maghrib = prayerSchedule.times.first(where: { $0.kind == .maghrib })?.date,
           let fajr = prayerSchedule.times.first(where: { $0.kind == .fajr })?.date {
            let nextFajr = fajr > maghrib ? fajr : fajr.addingTimeInterval(86400)
            let qiyam = engine.calculateQiyam(sunset: maghrib, fajrNextDay: nextFajr)
            self.qiyamTimeString = qiyam.formattedLastThird
            if isQiyamAlarmEnabled {
                NotificationService.shared.scheduleQiyamReminder(qiyamDate: qiyam.lastThirdStart)
            }
        }
    }
    
    private func startTimer() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    self.updateCountdownString()
                }
            }
        }
    }
    
    private func updateCountdownString() {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        self.countdownString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
}
