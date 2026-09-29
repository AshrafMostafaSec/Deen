import SwiftUI
import Observation

public struct PrayerCheckRecord: Identifiable, Sendable {
    public var id: String { kind.rawValue }
    public let kind: PrayerKind
    public let timeString: String
    public var isCompleted: Bool
    public var detailText: String
}

@MainActor
@Observable
public final class PrayerViewModel {
    public var locationTitle: String = "Locating..."
    public var calendarName: String = "Umm Al-Qura (Makkah)"
    public var solarAngleText: String = "--°"
    public var iqamahText: String = "Iqamah in 20 mins"
    public var adhanReciter: String = "Default Adhan"
    public var countdownString: String = "--:--:--"
    public var weeklyComplianceRate: Int = 0
    public var qiblaDegrees: Double = 0.0
    public var currentDeviceHeading: Double = 0.0
    
    public var nextPrayerName: String = "..."
    public var nextPrayerTime: String = "--:-- --"
    public var isAlignedWithQibla: Bool = false
    
    public var prayerRecords: [PrayerCheckRecord] = []
    
    private let engine = PrayerEngine()
    private var tickerTask: Task<Void, Never>?
    private var currentSchedule: PrayerSchedule?
    private var lastLatitude: Double = 24.7136
    private var lastLongitude: Double = 46.6753
    
    public var completedCount: Int {
        prayerRecords.filter { $0.kind.isObligatoryPrayer && $0.isCompleted }.count
    }
    
    public var totalObligatoryCount: Int {
        prayerRecords.filter { $0.kind.isObligatoryPrayer }.count
    }
    
    public init() {
        // Initialize with default fallback coordinates
        let schedule = engine.calculateSchedule(
            date: Date(),
            latitude: lastLatitude,
            longitude: lastLongitude,
            locationName: "Riyadh, Saudi Arabia"
        )
        applySchedule(schedule)
    }
    
    deinit {
        tickerTask?.cancel()
    }
    
    public func onAppear() {
        startCountdownTicker()
    }
    
    public func onDisappear() {
        stopCountdownTicker()
    }
    
    /// Called when location updates
    public func updateLocation(latitude: Double, longitude: Double, name: String) {
        self.lastLatitude = latitude
        self.lastLongitude = longitude
        self.locationTitle = name
        
        let schedule = engine.calculateSchedule(
            date: Date(),
            latitude: latitude,
            longitude: longitude,
            locationName: name
        )
        applySchedule(schedule)
    }
    
    public func updateHeading(_ heading: Double) {
        self.currentDeviceHeading = heading
        let diff = abs((qiblaDegrees - heading).truncatingRemainder(dividingBy: 360.0))
        let normalizedDiff = min(diff, 360.0 - diff)
        self.isAlignedWithQibla = normalizedDiff <= 4.0
    }
    
    public func togglePrayerCompletion(kind: PrayerKind) {
        if let idx = prayerRecords.firstIndex(where: { $0.kind == kind }) {
            prayerRecords[idx].isCompleted.toggle()
            prayerRecords[idx].detailText = prayerRecords[idx].isCompleted ? "Completed" : "Scheduled"
            
            // Persist to UserDefaults
            saveTodayCompletions()
            
            weeklyComplianceRate = totalObligatoryCount > 0
                ? (completedCount * 100 / totalObligatoryCount)
                : 0
            
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }
    }
    
    private func applySchedule(_ schedule: PrayerSchedule) {
        self.currentSchedule = schedule
        self.qiblaDegrees = engine.calculateQiblaBearing(latitude: lastLatitude, longitude: lastLongitude)
        
        if schedule.nextPrayer.kind == .sunrise {
            self.nextPrayerName = "Sunrise"
        } else {
            self.nextPrayerName = "\(schedule.nextPrayer.kind.rawValue) Prayer"
        }
        self.nextPrayerTime = schedule.nextPrayer.formattedTime
        self.solarAngleText = String(format: "%.1f°", schedule.solarAltitudeAngle)
        
        // Load persisted completions for today
        let savedCompletions = loadTodayCompletions()
        
        var newRecords: [PrayerCheckRecord] = []
        for item in schedule.times {
            let wasCompleted = savedCompletions[item.kind.rawValue] ?? false
            let detail: String
            if item.isCurrentOrNext {
                detail = "Upcoming • Next Prayer"
            } else if item.isPassed {
                detail = wasCompleted ? "Completed" : "Passed"
            } else {
                detail = "Scheduled"
            }
            
            newRecords.append(PrayerCheckRecord(
                kind: item.kind,
                timeString: item.formattedTime,
                isCompleted: wasCompleted,
                detailText: detail
            ))
        }
        self.prayerRecords = newRecords
        self.weeklyComplianceRate = totalObligatoryCount > 0 ? (completedCount * 100 / totalObligatoryCount) : 0
        updateCountdownString()
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
        guard let schedule = currentSchedule else { return }
        let now = Date()
        let remaining = Int(schedule.nextPrayer.date.timeIntervalSince(now))
        
        if remaining <= 0 {
            // Prayer time reached! Advance schedule
            let updated = engine.calculateSchedule(
                date: now,
                latitude: lastLatitude,
                longitude: lastLongitude,
                locationName: locationTitle
            )
            applySchedule(updated)
            return
        }
        
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        self.countdownString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Persistence
    
    private var todayDateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "deen.prayer.tracker.\(formatter.string(from: Date()))"
    }
    
    private func saveTodayCompletions() {
        let dict = Dictionary(uniqueKeysWithValues: prayerRecords.map { ($0.kind.rawValue, $0.isCompleted) })
        UserDefaults.standard.set(dict, forKey: todayDateKey)
    }
    
    private func loadTodayCompletions() -> [String: Bool] {
        UserDefaults.standard.dictionary(forKey: todayDateKey) as? [String: Bool] ?? [:]
    }
}
