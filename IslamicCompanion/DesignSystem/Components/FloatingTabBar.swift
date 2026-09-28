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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemIcon)
                            .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppColor.primary : AppColor.secondary.opacity(0.65))
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                        
                        Text(tab.rawValue)
                            .font(AppFont.interfaceLabel(size: 11, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppColor.primary : AppColor.secondary.opacity(0.65))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.spaceSm + 2)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.spaceSm)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(AppColor.surfaceContainer.opacity(0.85))
                .background(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
        }
        .padding(.horizontal, AppSpacing.spaceLg)
    }
}
