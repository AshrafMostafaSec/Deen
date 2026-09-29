import SwiftUI

public struct TodayView: View {
    @State private var viewModel = TodayViewModel()
    @Environment(\.locationService) private var locationService
    
    public let onNavigateToQuran: () -> Void
    public let onNavigateToAdhkar: () -> Void
    public let onNavigateToPrayer: () -> Void
    
    public init(
        onNavigateToQuran: @escaping () -> Void = {},
        onNavigateToAdhkar: @escaping () -> Void = {},
        onNavigateToPrayer: @escaping () -> Void = {}
    ) {
        self.onNavigateToQuran = onNavigateToQuran
        self.onNavigateToAdhkar = onNavigateToAdhkar
        self.onNavigateToPrayer = onNavigateToPrayer
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.spaceLg) {
                headerSection
                heroNextPrayerCard
                prayerTimelineSection
                quranGoalCard
                adhkarCard
                quranRadioCard
                qiyamCard
            }
            .padding(.horizontal, AppSpacing.margin)
            .padding(.top, AppSpacing.spaceSm)
            .padding(.bottom, 170) // Clearance for floating tab bar & mini-player
        }
        .background(AppColor.background.ignoresSafeArea())
        .onAppear {
            viewModel.onAppear()
            updateFromLocation()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .onChange(of: locationService.latitude) { _, _ in updateFromLocation() }
        .onChange(of: locationService.longitude) { _, _ in updateFromLocation() }
        .onChange(of: locationService.locationName) { _, _ in updateFromLocation() }
        .onChange(of: locationService.isLocationAvailable) { _, _ in updateFromLocation() }
    }
    
    private func updateFromLocation() {
        viewModel.updateLocation(
            latitude: locationService.latitude,
            longitude: locationService.longitude,
            name: locationService.locationName
        )
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.primary)
                    Text(viewModel.locationName)
                        .font(AppFont.interfaceLabel(size: 13))
                        .foregroundColor(AppColor.secondary)
                }
                
                Text(viewModel.hijriDateString)
                    .font(AppFont.interfaceLabel(size: 12))
                    .foregroundColor(AppColor.tertiary)
                
                Text("Assalamu Alaikum")
                    .font(AppFont.interface(size: 18, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Settings button
            Button {
                onNavigateToPrayer()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15))
                    .foregroundColor(AppColor.secondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(AppColor.surfaceContainerHigh))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }
    
    private var heroNextPrayerCard: some View {
        VStack(spacing: AppSpacing.spaceMd) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.prayerSchedule.nextPrayer.kind.iconName)
                        .foregroundColor(AppColor.primary)
                    Text("Next Prayer • \(viewModel.prayerSchedule.nextPrayer.kind.rawValue)")
                        .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                }
                
                Spacer()
                
                Text("LIVE")
                    .font(AppFont.technicalMetric(size: 10, weight: .bold))
                    .foregroundColor(AppColor.error)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.errorContainer.opacity(0.35))
                    .clipShape(Capsule())
            }
            
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.prayerSchedule.nextPrayer.formattedTime)
                        .font(AppFont.celestialDisplay(size: 40))
                        .foregroundColor(AppColor.onSurface)
                    
                    Text(viewModel.prayerSchedule.calculationMethod.rawValue)
                        .font(AppFont.interface(size: 12))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                        Text(viewModel.countdownString)
                            .font(AppFont.celestialDisplay(size: 20))
                    }
                    .foregroundColor(AppColor.primary)
                    
                    Text("Remaining")
                        .font(AppFont.interfaceLabel(size: 11))
                        .foregroundColor(AppColor.secondary)
                }
            }
            
            // Solar Arc Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.surfaceContainerLowest)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.primaryContainer, AppColor.primary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width, geo.size.width * solarAltitudeProgress)), height: 6)
                }
            }
            .frame(height: 6)
            .padding(.top, 4)
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true, showEmeraldGlow: true)
        .onTapGesture {
            onNavigateToPrayer()
        }
    }
    
    /// Maps solar altitude angle (-90° to +90°) into 0.0 - 1.0 progress
    private var solarAltitudeProgress: CGFloat {
        let angle = viewModel.prayerSchedule.solarAltitudeAngle
        let normalized = (angle + 90.0) / 180.0
        return CGFloat(max(0.05, min(0.95, normalized)))
    }
    
    private var prayerTimelineSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            HStack {
                Text("Today's Timeline")
                    .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Spacer()
                Button(action: onNavigateToPrayer) {
                    Text("View Full Schedule")
                        .font(AppFont.interfaceLabel(size: 12))
                        .foregroundColor(AppColor.primary)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 8) {
                ForEach(viewModel.prayerSchedule.times) { item in
                    let isNext = item.isCurrentOrNext
                    VStack(spacing: 6) {
                        Text(item.kind.rawValue)
                            .font(AppFont.interfaceLabel(size: 11, weight: isNext ? .bold : .regular))
                            .foregroundColor(isNext ? AppColor.primary : AppColor.onSurfaceVariant)
                        
                        Image(systemName: item.kind.iconName)
                            .font(.system(size: 15))
                            .foregroundColor(isNext ? AppColor.primary : AppColor.secondary.opacity(0.7))
                        
                        Text(shortTime(item.formattedTime))
                            .font(AppFont.technicalMetric(size: 11))
                            .foregroundColor(isNext ? AppColor.onSurface : AppColor.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.small + 4, style: .continuous)
                            .fill(isNext ? AppColor.primaryContainer.opacity(0.4) : AppColor.surfaceContainerLow)
                    }
                    .overlay {
                        if isNext {
                            RoundedRectangle(cornerRadius: AppRadius.small + 4, style: .continuous)
                                .stroke(AppColor.primary.opacity(0.6), lineWidth: 1)
                        }
                    }
                }
            }
        }
    }
    
    private func shortTime(_ time: String) -> String {
        time.replacingOccurrences(of: " AM", with: "").replacingOccurrences(of: " PM", with: "")
    }
    
    private var quranGoalCard: some View {
        HStack(spacing: AppSpacing.spaceMd) {
            ZStack {
                Circle()
                    .fill(AppColor.surfaceContainerHigh)
                    .frame(width: 48, height: 48)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColor.primary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Daily Quran Goal")
                    .font(AppFont.interfaceLabel(size: 12))
                    .foregroundColor(AppColor.secondary)
                Text(viewModel.quranSurahName)
                    .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Text("Page \(viewModel.quranPage) • \(viewModel.quranCompletedPages) of \(viewModel.quranGoalPages) pages completed")
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.onSurfaceVariant)
            }
            
            Spacer()
            
            Button(action: onNavigateToQuran) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.onPrimary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(AppColor.primary))
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
    
    private var adhkarCard: some View {
        HStack(spacing: AppSpacing.spaceMd) {
            ZStack {
                Circle()
                    .fill(AppColor.tertiaryContainer.opacity(0.5))
                    .frame(width: 48, height: 48)
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(AppColor.tertiary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.adhkarTitle)
                    .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Text("\(viewModel.adhkarCompleted) of \(viewModel.adhkarTotal) Completed")
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.onSurfaceVariant)
            }
            
            Spacer()
            
            Button(action: onNavigateToAdhkar) {
                Text("Resume")
                    .font(AppFont.interfaceLabel(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.onPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(AppColor.primary))
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
    
    private var quranRadioCard: some View {
        let isPlayingRadio = AudioService.shared.isLiveRadio && AudioService.shared.isPlaying
        
        return HStack(spacing: AppSpacing.spaceMd) {
            ZStack {
                Circle()
                    .fill(AppColor.primaryContainer.opacity(0.8))
                    .frame(width: 48, height: 48)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 20))
                    .foregroundColor(AppColor.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text("Quran Radio Cairo")
                        .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                    
                    Text("98.2 FM")
                        .font(AppFont.technicalMetric(size: 11, weight: .bold))
                        .foregroundColor(AppColor.tertiary)
                }
                
                Text("إذاعة القرآن الكريم من القاهرة • Live")
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.onSurfaceVariant)
            }
            
            Spacer()
            
            Button {
                if isPlayingRadio {
                    AudioService.shared.togglePlayPause()
                } else {
                    let cairoStation = RadioViewModel.fallbackStations.first(where: { $0.id == "quran-radio-cairo" }) ?? RadioViewModel.fallbackStations[0]
                    AudioService.shared.playRadio(station: cairoStation)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColor.primary)
                        .frame(width: 36, height: 36)
                    Image(systemName: isPlayingRadio ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.onPrimary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
    
    private var qiyamCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(AppColor.tertiary)
                        .font(.system(size: 13))
                    Text("Qiyam Al-Layl")
                        .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                }
                
                Text("Last Third starts at \(viewModel.qiyamTimeString)")
                    .font(AppFont.interface(size: 12))
                    .foregroundColor(AppColor.secondary)
            }
            
            Spacer()
            
            Button {
                viewModel.toggleQiyamAlarm()
            } label: {
                Image(systemName: viewModel.isQiyamAlarmEnabled ? "bell.fill" : "bell.slash")
                    .font(.system(size: 15))
                    .foregroundColor(viewModel.isQiyamAlarmEnabled ? AppColor.primary : AppColor.outline)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(viewModel.isQiyamAlarmEnabled ? AppColor.primaryContainer.opacity(0.6) : AppColor.surfaceContainerHigh)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
}
