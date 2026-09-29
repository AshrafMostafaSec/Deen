import SwiftUI

public struct FloatingMiniPlayer: View {
    public let title: String
    public let subtitle: String
    public let isPlaying: Bool
    public let isLiveRadio: Bool
    public let onPlayPause: @MainActor () -> Void
    public let onClose: @MainActor () -> Void
    public let onTap: @MainActor () -> Void
    
    public init(
        title: String,
        subtitle: String,
        isPlaying: Bool,
        isLiveRadio: Bool = false,
        onPlayPause: @escaping @MainActor () -> Void,
        onClose: @escaping @MainActor () -> Void,
        onTap: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isPlaying = isPlaying
        self.isLiveRadio = isLiveRadio
        self.onPlayPause = onPlayPause
        self.onClose = onClose
        self.onTap = onTap
    }
    
    public var body: some View {
        HStack(spacing: AppSpacing.spaceSm) {
            // Main Tappable Info Area
            Button(action: onTap) {
                HStack(spacing: AppSpacing.spaceMdSm) {
                    // Artwork / Icon Glyph
                    ZStack {
                        Circle()
                            .fill(AppColor.primaryContainer.opacity(0.85))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: isLiveRadio ? "dot.radiowaves.left.and.right" : "book.closed.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                    }
                    
                    // Metadata Details
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.onSurface)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            if isLiveRadio {
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(AppColor.error)
                                        .frame(width: 5, height: 5)
                                    Text("LIVE")
                                        .font(AppFont.technicalMetric(size: 9, weight: .bold))
                                        .foregroundColor(AppColor.error)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(AppColor.errorContainer.opacity(0.4))
                                .clipShape(Capsule())
                                .layoutPriority(1)
                            }
                        }
                        
                        Text(subtitle)
                            .font(AppFont.interface(size: 11))
                            .foregroundColor(AppColor.onSurfaceVariant)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Controls
            HStack(spacing: 0) {
                // Play/Pause Action with 44x44 touch target
                Button(action: onPlayPause) {
                    ZStack {
                        Circle()
                            .fill(AppColor.primary)
                            .frame(width: 34, height: 34)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.onPrimary)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                // Dismiss Action with 44x44 touch target
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.onSurfaceVariant)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, AppSpacing.spaceMd)
        .padding(.trailing, AppSpacing.spaceXs)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.surfaceContainerLowest.opacity(0.85))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
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
                .shadow(color: Color.black.opacity(0.45), radius: 20, x: 0, y: 8)
        }
        .padding(.horizontal, AppSpacing.spaceMd)
    }
}
