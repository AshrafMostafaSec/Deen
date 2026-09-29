import SwiftUI

public struct RootTabView: View {
    @State private var selectedTab: NavigationTab = .today
    @State private var isRadioSheetPresented: Bool = false
    
    // Connect to shared services
    private var audioService = AudioService.shared
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Content
            Group {
                switch selectedTab {
                case .today:
                    TodayView(
                        onNavigateToQuran: { selectedTab = .quran },
                        onNavigateToAdhkar: { selectedTab = .adhkar },
                        onNavigateToPrayer: { selectedTab = .prayer }
                    )
                case .quran:
                    QuranHomeView()
                case .prayer:
                    PrayerView()
                case .adhkar:
                    AdhkarView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Floating Controls Stack (Mini-Player + Tab Bar)
            VStack(spacing: 8) {
                // Persistent Floating Mini-Player
                if !audioService.currentTitle.isEmpty {
                    FloatingMiniPlayer(
                        title: audioService.currentTitle,
                        subtitle: audioService.currentSubtitle,
                        isPlaying: audioService.isPlaying,
                        isLiveRadio: audioService.isLiveRadio,
                        onPlayPause: {
                            audioService.togglePlayPause()
                        },
                        onClose: {
                            audioService.stop()
                        },
                        onTap: {
                            if audioService.isLiveRadio {
                                isRadioSheetPresented = true
                            } else {
                                selectedTab = .quran
                            }
                        }
                    )
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95, anchor: .bottom)),
                            removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95, anchor: .bottom))
                        )
                    )
                }
                
                // Floating Bottom Tab Bar
                FloatingTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 8)
            .animation(.spring(response: 0.38, dampingFraction: 0.82), value: !audioService.currentTitle.isEmpty)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isRadioSheetPresented) {
            RadioView()
        }
    }
}
