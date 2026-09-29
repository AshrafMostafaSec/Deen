import SwiftUI

public enum NavigationTab: String, CaseIterable, Identifiable, Sendable {
    case today = "Today"
    case quran = "Quran"
    case prayer = "Prayer"
    case adhkar = "Adhkar"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .today: return "sun.horizon.fill"
        case .quran: return "book.closed.fill"
        case .prayer: return "clock.fill"
        case .adhkar: return "sparkles"
        }
    }
}

public struct FloatingTabBar: View {
    @Binding var selectedTab: NavigationTab
    
    public init(selectedTab: Binding<NavigationTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemIcon)
                            .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppColor.primary : AppColor.onSurfaceVariant)
                            .scaleEffect(isSelected ? 1.08 : 1.0)
                        
                        Text(tab.rawValue)
                            .font(AppFont.tabLabel(size: 11, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? AppColor.primary : AppColor.onSurfaceVariant)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .padding(.vertical, 8)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(AppColor.primaryContainer.opacity(0.28))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(AppColor.surfaceContainerLowest.opacity(0.82))
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule()
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
                .shadow(color: Color.black.opacity(0.55), radius: 24, x: 0, y: 10)
        }
        .padding(.horizontal, AppSpacing.spaceMd)
    }
}
