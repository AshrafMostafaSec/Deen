import SwiftUI

public struct RootTabView: View {
    @State private var selectedTab: NavigationTab = .today
    @State private var isRadioSheetPresented: Bool = false
    
    // Connect to shared audio service
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Floating Bottom Tab Bar
                FloatingTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isRadioSheetPresented) {
            RadioView()
        }
    }
}
