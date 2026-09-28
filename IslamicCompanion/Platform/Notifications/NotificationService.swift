import Foundation
import UserNotifications

@MainActor
public final class NotificationService {
    public static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    public init() {}
    
    /// Requests notification permissions gracefully from the user.
    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    /// Schedules daily prayer notifications and pre-prayer reminders.
    public func schedulePrayerReminders(schedule: PrayerSchedule, prePrayerReminderMinutes: Int = 15) {
        let calendar = Calendar.current
        let now = Date()
        
        for item in schedule.times where item.kind.isObligatoryPrayer {
            let id = "deen.prayer.\(item.kind.rawValue.lowercased())"
            
            // 1. Adhan Notification
            if item.date > now {
                let content = UNMutableNotificationContent()
                content.title = "\(item.kind.rawValue) Prayer • صلاة \(item.kind.arabicName)"
                content.body = "It is now time for \(item.kind.rawValue) prayer. حي على الصلاة."
                content.sound = .default
                
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: item.date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                center.add(request)
            }
            
            // 2. Pre-prayer Reminder (e.g. 15 minutes prior)
            if prePrayerReminderMinutes > 0 {
                let preDate = item.date.addingTimeInterval(-Double(prePrayerReminderMinutes * 60))
                if preDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = "Upcoming: \(item.kind.rawValue) Prayer"
                    content.body = "\(item.kind.rawValue) prayer will begin in \(prePrayerReminderMinutes) minutes. Prepare for prayer."
                    content.sound = .default
                    
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: preDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: "\(id).pre", content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }
    
    /// Schedules Qiyam Al-Layl (last third of the night) notification.
    public func scheduleQiyamReminder(qiyamDate: Date) {
        guard qiyamDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Qiyam Al-Layl • قيام الليل"
        content.body = "The blessed last third of the night has commenced. A time of descent, prayer, and acceptance."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: qiyamDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "deen.qiyam", content: content, trigger: trigger)
        center.add(request)
    }
    
    /// Schedules Morning and Evening Adhkar daily recurring reminders.
    public func scheduleDailyAdhkarReminders(
        morningHour: Int = 6,
        morningMinute: Int = 0,
        eveningHour: Int = 17,
        eveningMinute: Int = 0
    ) {
        // Morning Adhkar
        var morningComponents = DateComponents()
        morningComponents.hour = morningHour
        morningComponents.minute = morningMinute
        
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Morning Adhkar • أذكار الصباح"
        morningContent.body = "Begin your morning with remembrance and protection."
        morningContent.sound = .default
        
        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningComponents, repeats: true)
        let morningRequest = UNNotificationRequest(identifier: "deen.adhkar.morning", content: morningContent, trigger: morningTrigger)
        center.add(morningRequest)
        
        // Evening Adhkar
        var eveningComponents = DateComponents()
        eveningComponents.hour = eveningHour
        eveningComponents.minute = eveningMinute
        
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Evening Adhkar • أذكار المساء"
        eveningContent.body = "Fortify yourself this evening with remembrance and gratitude."
        eveningContent.sound = .default
        
        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComponents, repeats: true)
        let eveningRequest = UNNotificationRequest(identifier: "deen.adhkar.evening", content: eveningContent, trigger: eveningTrigger)
        center.add(eveningRequest)
    }
    
    /// Cancels all pending notifications
    public func removeAllPendingReminders() {
        center.removeAllPendingNotificationRequests()
    }
}
