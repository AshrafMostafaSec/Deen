import SwiftUI

/// Typography helpers ensuring clean pairing of Space Grotesk, Geist, and Arabic Uthmanic type
public enum AppFont {
    /// Space Grotesk equivalent for technical countdowns, angles, and celestial degrees
    public static func celestialDisplay(size: CGFloat = 36, weight: Font.Weight = .semibold) -> Font {
        Font.custom("SpaceGrotesk-SemiBold", size: size)
            .monospacedDigit()
    }
    
    /// Technical timestamp or degree metric with tabular lining figures
    public static func technicalMetric(size: CGFloat = 20, weight: Font.Weight = .medium) -> Font {
        Font.custom("SpaceGrotesk-Medium", size: size)
            .monospacedDigit()
    }
    
    /// Standard interface label and body text (Geist / SF Pro)
    public static func interface(size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        Font.custom("Geist-Regular", size: size)
    }
    
    /// Bold/Medium interface label
    public static func interfaceLabel(size: CGFloat = 13, weight: Font.Weight = .medium) -> Font {
        Font.custom("Geist-Medium", size: size)
    }
    
    /// Authentic Arabic scripture typography (Amiri / Uthmanic)
    public static func quranScripture(size: CGFloat = 22) -> Font {
        Font.custom("Amiri-Regular", size: size)
    }
    
    /// Authentic Arabic title / heading
    public static func arabicHeading(size: CGFloat = 18, weight: Font.Weight = .semibold) -> Font {
        Font.custom("Amiri-Bold", size: size)
    }
}
