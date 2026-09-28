import SwiftUI

/// Continuous Apple Squircle Corner Radii
public enum AppRadius {
    /// 8pt - Micro chips, badges
    public static let small: CGFloat = 8
    /// 16pt - Standard input buttons, small tiles
    public static let medium: CGFloat = 16
    /// 24pt - Astrolabe content cards
    public static let card: CGFloat = 24
    /// 32pt - Hero panels, macro containers
    public static let large: CGFloat = 32
    /// 48pt - Main astrolabe instrument plate
    public static let xlarge: CGFloat = 48
    /// 9999pt - Full pill controls
    public static let capsule: CGFloat = 9999
}

/// Layout and Rhythm Spacing Tokens
public enum AppSpacing {
    /// 4pt
    public static let spaceXs: CGFloat = 4
    /// 8pt
    public static let spaceSm: CGFloat = 8
    /// 12pt
    public static let spaceMdSm: CGFloat = 12
    /// 16pt
    public static let spaceMd: CGFloat = 16
    /// 20pt
    public static let margin: CGFloat = 20
    /// 24pt
    public static let spaceLg: CGFloat = 24
    /// 32pt
    public static let spaceXl: CGFloat = 32
    /// 40pt
    public static let space2Xl: CGFloat = 40
}
