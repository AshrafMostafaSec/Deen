import SwiftUI

public struct FloatingMiniPlayer: View {
    public let title: String
    public let subtitle: String
    public let isPlaying: Bool
    public let isLiveRadio: Bool
    public let onPlayPause: () -> Void
    public let onClose: () -> Void
    public let onTap: () -> Void
    
    public init(
        title: String,
        subtitle: String,
        isPlaying: Bool,
        isLiveRadio: Bool = false,
        onPlayPause: @escaping () -> Void,
        onClose: @escaping () -> Void,
        onTap: @escaping () -> Void
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
        HStack(spacing: AppSpacing.spaceMdSm) {
            // Icon / Station Artwork indicator
            ZStack {
                Circle()
                    .fill(AppColor.primaryContainer.opacity(0.8))
                    .frame(width: 38, height: 38)
                
                Image(systemName: isLiveRadio ? "dot.radiowaves.left.and.right" : "book.closed.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.primary)
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                        .lineLimit(1)
                    
                    if isLiveRadio {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 5, height: 5)
                            Text("LIVE")
                                .font(AppFont.technicalMetric(size: 9, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.red.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
                
                Text(subtitle)
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.onSurfaceVariant)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Play/Pause Action
            Button(action: onPlayPause) {
                ZStack {
                    Circle()
                        .fill(AppColor.primary)
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.onPrimary)
                }
            }
            .buttonStyle(.plain)
            
            // Dismiss Action
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.outline)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.spaceMd)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.surfaceContainerHigh.opacity(0.92))
                .background(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .padding(.horizontal, AppSpacing.spaceMd)
        .onTapGesture {
            onTap()
        }
    }
}
