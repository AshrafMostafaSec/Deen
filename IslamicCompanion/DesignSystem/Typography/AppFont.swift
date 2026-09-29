import SwiftUI

/// Typography helpers using system fonts with proper weight mapping.
public enum AppFont {
    /// Monospaced display for technical countdowns, celestial degrees, timers
    public static func celestialDisplay(size: CGFloat = 36, weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
    
    /// Technical timestamp or degree metric with tabular lining figures
    public static func technicalMetric(size: CGFloat = 20, weight: Font.Weight = .medium) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
    
    /// Standard interface label and body text
    public static func interface(size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
    
    /// Medium/Bold interface label
    public static func interfaceLabel(size: CGFloat = 13, weight: Font.Weight = .medium) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
    
    /// Tab bar & compact navigation label (matches design system label-sm: 11pt, semibold)
    public static func tabLabel(size: CGFloat = 11, weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
    
    /// Arabic scripture typography — uses serif design for authentic rendering
    public static func quranScripture(size: CGFloat = 22) -> Font {
        Font.system(size: size, weight: .regular, design: .serif)
    }
    
    /// Arabic title / heading — uses serif bold
    public static func arabicHeading(size: CGFloat = 18, weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }
}
