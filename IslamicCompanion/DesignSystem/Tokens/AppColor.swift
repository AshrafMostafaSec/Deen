import SwiftUI

/// Semantic Design Tokens for Aetherial Astrolabe Design System
public enum AppColor {
    // Canvas & Surfaces
    public static let background = Color(hex: "#111413")
    public static let surface = Color(hex: "#151A18")
    public static let surfaceDim = Color(hex: "#111413")
    public static let surfaceBright = Color(hex: "#373A38")
    
    public static let surfaceContainerLowest = Color(hex: "#0C0F0E")
    public static let surfaceContainerLow = Color(hex: "#191C1B")
    public static let surfaceContainer = Color(hex: "#1D201F")
    public static let surfaceContainerHigh = Color(hex: "#282B29")
    public static let surfaceContainerHighest = Color(hex: "#323534")
    
    // Primary - Cypress Emerald Sage
    public static let primary = Color(hex: "#9DD2B3")
    public static let primaryContainer = Color(hex: "#2A5C43")
    public static let onPrimary = Color(hex: "#003823")
    public static let onPrimaryContainer = Color(hex: "#9DD2B3")
    public static let primaryFixedDim = Color(hex: "#9DD2B3")
    
    // Secondary - Lichen Mist
    public static let secondary = Color(hex: "#B3CCBF")
    public static let secondaryContainer = Color(hex: "#384E44")
    public static let onSecondary = Color(hex: "#1F352C")
    public static let onSecondaryContainer = Color(hex: "#A6BEB1")
    
    // Tertiary - Celestial Desert Sand / Golden Starlight
    public static let tertiary = Color(hex: "#E0C298")
    public static let tertiaryContainer = Color(hex: "#654F2E")
    public static let onTertiary = Color(hex: "#402D0F")
    public static let onTertiaryContainer = Color(hex: "#E0C298")
    
    // Typography Content
    public static let onSurface = Color(hex: "#E1E3E1")
    public static let onSurfaceVariant = Color(hex: "#C0C9C1")
    public static let outline = Color(hex: "#8A938C")
    public static let outlineVariant = Color(hex: "#414943")
    
    // Precision Astrolabe Rim & Highlights
    public static let hairlineBorder = Color.white.opacity(0.08)
    public static let specularGlow = Color(hex: "#2A5C43").opacity(0.35)
}

public extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 17, 20, 19)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
