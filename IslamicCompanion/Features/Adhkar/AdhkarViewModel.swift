import SwiftUI
import Observation

public struct AdhkarCategoryItem: Identifiable, Codable, Sendable {
    public let id: String
    public let titleEnglish: String
    public let titleArabic: String
    public let countText: String
    public let iconName: String
    public let isReady: Bool
    public let completedItems: Int
    public let totalItems: Int
}

@MainActor
@Observable
public final class AdhkarViewModel {
    public var totalCompleted: Int = 32
    public var totalCount: Int = 48
    public var isHapticEnabled: Bool = true
    
    // Focused Tasbeeh Pad State
    public var currentTasbeehCount: Int = 33
    public var maxTasbeehCount: Int = 100
    public var currentDhikrText: String = "« سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ »"
    public var currentDhikrVirtue: String = "Light on the tongue, heavy in the scales."
    
    public var categories: [AdhkarCategoryItem] = [
        AdhkarCategoryItem(id: "morning", titleEnglish: "Morning Adhkar", titleArabic: "أذكار الصباح", countText: "24 items • 18 completed", iconName: "sun.max.fill", isReady: false, completedItems: 18, totalItems: 24),
        AdhkarCategoryItem(id: "evening", titleEnglish: "Evening Adhkar", titleArabic: "أذكار المساء", countText: "24 items • Ready to read", iconName: "moon.fill", isReady: true, completedItems: 0, totalItems: 24),
        AdhkarCategoryItem(id: "post_prayer", titleEnglish: "After Prayer", titleArabic: "أذكار بعد الصلاة", countText: "8 items • Tasbeeh & Istighfar", iconName: "hands.sparkles.fill", isReady: false, completedItems: 8, totalItems: 8),
        AdhkarCategoryItem(id: "sleep", titleEnglish: "Sleep Adhkar", titleArabic: "أذكار النوم", countText: "12 items • Peace & tranquility", iconName: "bed.double.fill", isReady: false, completedItems: 0, totalItems: 12)
    ]
    
    public var completionPercentage: Int {
        Int((Double(totalCompleted) / Double(totalCount)) * 100.0)
    }
    
    public func incrementTasbeeh() {
        if currentTasbeehCount < maxTasbeehCount {
            currentTasbeehCount += 1
        } else {
            currentTasbeehCount = 1
        }
        triggerHaptic()
    }
    
    public func resetTasbeeh() {
        currentTasbeehCount = 0
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
}
