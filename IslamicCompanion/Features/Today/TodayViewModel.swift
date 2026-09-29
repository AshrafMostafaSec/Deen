import SwiftUI
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    public var locationName: String = "Locating..."
    public var hijriDateString: String = ""
    
    public var prayerSchedule: PrayerSchedule
    public var countdownString: String = "--:--:--"
    public var qiyamTimeString: String = "--:-- AM"
    public var isQiyamAlarmEnabled: Bool = true
    
    // Quran Progress
    public var quranSurahName: String = "Surah Al-Kahf"
    public var quranPage: Int = 293
    public var quranCompletedPages: Int = 4
    public var quranGoalPages: Int = 6
    
    // Adhkar Progress
    public var adhkarTitle: String = "Morning Adhkar"
    public var adhkarCompleted: Int = 5
    public var adhkarTotal: Int = 7
    
    private let engine = PrayerEngine()
    private var tickerTask: Task<Void, Never>?
    private var lastLatitude: Double = 24.7136
    private var lastLongitude: Double = 46.6753
    
    public init() {
        let defaultLat = 24.7136
        let defaultLon = 46.6753
        self.lastLatitude = defaultLat
        self.lastLongitude = defaultLon
        self.prayerSchedule = engine.calculateSchedule(
            date: Date(),
            latitude: defaultLat,
            longitude: defaultLon,
            locationName: "Riyadh, Saudi Arabia"
        )
        updateCountdownString()
        refreshDateStrings()
    }
    
    public func onAppear() {
        refreshDateStrings()
        startCountdownTicker()
        updateRemindersAndQiyam()
    }
    
    public func onDisappear() {
        stopCountdownTicker()
    }
    
    /// Called when location updates
    public func updateLocation(latitude: Double, longitude: Double, name: String) {
        self.lastLatitude = latitude
        self.lastLongitude = longitude
        self.locationName = name
        self.prayerSchedule = engine.calculateSchedule(
            date: Date(),
            latitude: latitude,
            longitude: longitude,
            locationName: name
        )
        updateCountdownString()
        updateRemindersAndQiyam()
    }
    
    public func toggleQiyamAlarm() {
        isQiyamAlarmEnabled.toggle()
        if !isQiyamAlarmEnabled {
            NotificationService.shared.cancelQiyamReminder()
        } else {
            updateRemindersAndQiyam()
        }
    }
    
    public func updateRemindersAndQiyam() {
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
    
    private func startCountdownTicker() {
        stopCountdownTicker()
        tickerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self else { break }
                self.updateCountdownString()
            }
        }
    }
    
    private func stopCountdownTicker() {
        tickerTask?.cancel()
        tickerTask = nil
    }
    
    private func updateCountdownString() {
        let now = Date()
        let remaining = Int(prayerSchedule.nextPrayer.date.timeIntervalSince(now))
        
        if remaining <= 0 {
            // Auto advance
            self.prayerSchedule = engine.calculateSchedule(
                date: now,
                latitude: lastLatitude,
                longitude: lastLongitude,
                locationName: locationName
            )
            return
        }
        
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        self.countdownString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    public func refreshDateStrings() {
        let now = Date()
        let hijri = Calendar(identifier: .islamicUmmAlQura)
        let hDay = hijri.component(.day, from: now)
        let hMonth = hijri.component(.month, from: now)
        let hYear = hijri.component(.year, from: now)
        
        let hijriMonthNames = ["", "Muharram", "Safar", "Rabi' I", "Rabi' II", "Jumada I", "Jumada II",
                               "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhul Qi'dah", "Dhul Hijjah"]
        let monthName = hMonth >= 1 && hMonth <= 12 ? hijriMonthNames[hMonth] : ""
        
        let greg = DateFormatter()
        greg.dateFormat = "d MMMM"
        greg.locale = Locale(identifier: "en_US")
        let gregStr = greg.string(from: now)
        
        self.hijriDateString = "\(hDay) \(monthName) \(hYear) AH • \(gregStr)"
        
        // Contextual Adhkar by time of day
        let hour = Calendar.current.component(.hour, from: now)
        if hour >= 4 && hour < 12 {
            self.adhkarTitle = "Morning Adhkar"
            self.adhkarCompleted = 5
            self.adhkarTotal = 7
        } else if hour >= 12 && hour < 20 {
            self.adhkarTitle = "Evening Adhkar"
            self.adhkarCompleted = 3
            self.adhkarTotal = 5
        } else {
            self.adhkarTitle = "Sleep Adhkar"
            self.adhkarCompleted = 1
            self.adhkarTotal = 3
        }
    }
}
