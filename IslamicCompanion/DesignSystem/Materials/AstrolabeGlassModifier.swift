import SwiftUI

/// Glassmorphism modifier applying the Aetherial Astrolabe Liquid Glass shader aesthetic
public struct AstrolabeGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var isElevated: Bool
    var showEmeraldGlow: Bool

    public init(
        cornerRadius: CGFloat = AppRadius.card,
        isElevated: Bool = false,
        showEmeraldGlow: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.isElevated = isElevated
        self.showEmeraldGlow = showEmeraldGlow
    }

    public func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        isElevated
                        ? AppColor.surfaceContainer.opacity(0.78)
                        : AppColor.surfaceContainerLow.opacity(0.68)
                    )
                    .background(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                // Directional specular rim highlight
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.16),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.01)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .overlay {
                if showEmeraldGlow {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppColor.primary.opacity(0.4), lineWidth: 1.5)
                        .shadow(color: AppColor.primaryContainer.opacity(0.5), radius: 10, x: 0, y: 0)
                }
            }
    }
}

public extension View {
    func astrolabeGlass(
        cornerRadius: CGFloat = AppRadius.card,
        isElevated: Bool = false,
        showEmeraldGlow: Bool = false
    ) -> some View {
        modifier(AstrolabeGlassModifier(
            cornerRadius: cornerRadius,
            isElevated: isElevated,
            showEmeraldGlow: showEmeraldGlow
        ))
    }
}
