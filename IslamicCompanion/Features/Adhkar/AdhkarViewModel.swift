import SwiftUI
import Observation

public struct AdhkarCategoryItem: Identifiable, Codable, Sendable {
    public let id: String
    public let titleEnglish: String
    public let titleArabic: String
    public let countText: String
    public let iconName: String
    public let isReady: Bool
    public var completedItems: Int
    public var totalItems: Int
}

@MainActor
@Observable
public final class AdhkarViewModel {
    public var totalCompleted: Int = 0
    public var totalCount: Int = 21
    public var isHapticEnabled: Bool = true
    
    // Focused Tasbeeh Pad State
    public var currentTasbeehCount: Int = 0
    public var maxTasbeehCount: Int = 100
    public var currentDhikrText: String = "« سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ »"
    public var currentDhikrVirtue: String = "Light on the tongue, heavy in the scales."
    
    public var selectedCategoryForSheet: AdhkarCategoryItem? = nil
    public var fortressCatalog: AdhkarFortressCatalog = AdhkarFortressCatalog()
    public var itemProgress: [String: Int] = [:]
    
    public var categories: [AdhkarCategoryItem] = [
        AdhkarCategoryItem(id: "morning", titleEnglish: "Morning Adhkar", titleArabic: "أذكار الصباح", countText: "7 authentic items • Protection", iconName: "sun.max.fill", isReady: true, completedItems: 0, totalItems: 7),
        AdhkarCategoryItem(id: "evening", titleEnglish: "Evening Adhkar", titleArabic: "أذكار المساء", countText: "5 authentic items • Serenity", iconName: "moon.fill", isReady: false, completedItems: 0, totalItems: 5),
        AdhkarCategoryItem(id: "post_prayer", titleEnglish: "After Prayer", titleArabic: "أذكار بعد الصلاة", countText: "6 authentic items • Tasbeeh", iconName: "hands.sparkles.fill", isReady: false, completedItems: 0, totalItems: 6),
        AdhkarCategoryItem(id: "sleep", titleEnglish: "Sleep Adhkar", titleArabic: "أذكار النوم", countText: "3 authentic items • Tranquility", iconName: "bed.double.fill", isReady: false, completedItems: 0, totalItems: 3)
    ]
    
    public init() {
        loadCatalog()
    }
    
    public func loadCatalog() {
        if let url = Bundle.main.url(forResource: "adhkar_fortress", withExtension: "json") ??
                     Bundle.main.url(forResource: "adhkar_fortress", withExtension: "json", subdirectory: "Adhkar"),
           let data = try? Data(contentsOf: url),
           let catalog = try? JSONDecoder().decode(AdhkarFortressCatalog.self, from: data) {
            self.fortressCatalog = catalog
        } else {
            self.fortressCatalog = Self.fallbackCatalog
        }
        
        self.totalCount = fortressCatalog.morning.count + fortressCatalog.evening.count + fortressCatalog.post_prayer.count + fortressCatalog.sleep.count
        
        for i in 0..<categories.count {
            let id = categories[i].id
            let count = fortressCatalog.items(for: id).count
            categories[i] = AdhkarCategoryItem(
                id: categories[i].id,
                titleEnglish: categories[i].titleEnglish,
                titleArabic: categories[i].titleArabic,
                countText: "\(count) authentic items • Hisn Al-Muslim",
                iconName: categories[i].iconName,
                isReady: categories[i].isReady,
                completedItems: categories[i].completedItems,
                totalItems: count
            )
        }
    }
    
    public var completionPercentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(totalCompleted) / Double(totalCount)) * 100.0)
    }
    
    public func incrementTasbeeh() {
        if currentTasbeehCount < maxTasbeehCount {
            currentTasbeehCount += 1
            if currentTasbeehCount == maxTasbeehCount {
                triggerSuccessHaptic()
            } else {
                triggerHaptic()
            }
        } else {
            currentTasbeehCount = 1
            triggerHaptic()
        }
    }
    
    public func resetTasbeeh() {
        currentTasbeehCount = 0
        triggerHaptic()
    }
    
    public func incrementItem(item: AdhkarItem) {
        let current = itemProgress[item.id] ?? 0
        if current < item.targetCount {
            let next = current + 1
            itemProgress[item.id] = next
            if next == item.targetCount {
                totalCompleted += 1
                triggerSuccessHaptic()
            } else {
                triggerHaptic()
            }
        }
    }
    
    public func resetItem(item: AdhkarItem) {
        if let current = itemProgress[item.id], current >= item.targetCount {
            totalCompleted = max(0, totalCompleted - 1)
        }
        itemProgress[item.id] = 0
        triggerHaptic()
    }
    
    public func toggleHaptic() {
        isHapticEnabled.toggle()
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        if isHapticEnabled {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
        #endif
    }
    
    private func triggerSuccessHaptic() {
        #if os(iOS)
        if isHapticEnabled {
            let notify = UINotificationFeedbackGenerator()
            notify.notificationOccurred(.success)
        }
        #endif
    }
    
    nonisolated public static let fallbackCatalog = AdhkarFortressCatalog(
        morning: [
            AdhkarItem(id: "m1", textArabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ", textEnglish: "We have reached the morning and the dominion belongs to Allah, and all praise is to Allah.", targetCount: 1, reference: "Sahih Muslim"),
            AdhkarItem(id: "m2", textArabic: "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ", textEnglish: "O Allah, by You we enter the morning and by You we enter the evening.", targetCount: 1, reference: "Sunan At-Tirmidhi"),
            AdhkarItem(id: "m3", textArabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ", textEnglish: "Glory is to Allah and praise is to Him.", targetCount: 100, reference: "Sahih Muslim")
        ],
        evening: [
            AdhkarItem(id: "e1", textArabic: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ", textEnglish: "We have reached the evening and the kingdom belongs to Allah.", targetCount: 1, reference: "Sahih Muslim"),
            AdhkarItem(id: "e2", textArabic: "اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ", textEnglish: "O Allah, whatever blessing has reached me this evening is from You alone.", targetCount: 1, reference: "Sunan Abu Dawud")
        ],
        post_prayer: [
            AdhkarItem(id: "p1", textArabic: "أَسْتَغْفِرُ اللَّهَ ، أَسْتَغْفِرُ اللَّهَ ، أَسْتَغْفِرُ اللَّهَ", textEnglish: "I ask Allah for forgiveness (thrice).", targetCount: 3, reference: "Sahih Muslim"),
            AdhkarItem(id: "p2", textArabic: "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ", textEnglish: "O Allah, You are peace and from You is peace.", targetCount: 1, reference: "Sahih Muslim")
        ],
        sleep: [
            AdhkarItem(id: "s1", textArabic: "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ", textEnglish: "In Your name, my Lord, I lie down, and by Your name I rise.", targetCount: 1, reference: "Sahih Al-Bukhari"),
            AdhkarItem(id: "s2", textArabic: "اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ", textEnglish: "O Allah, protect me from Your punishment on the Day You resurrect Your servants.", targetCount: 3, reference: "Sunan Abu Dawud")
        ]
    )
}
