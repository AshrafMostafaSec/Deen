import SwiftUI

public struct PrayerView: View {
    @State private var viewModel = PrayerViewModel()
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.spaceLg) {
                // Header Banner
                headerBanner
                
                // Next Prayer Detailed Card
                heroNextPrayerCard
                
                // Daily Prayer Interactive Tracker List
                prayerTrackerSection
                
                // Astronomical Utility Grid (Qibla, Weekly stats, Qiyam)
                astronomicalUtilityGrid
                
                // Spiritual Quote
                ayahBanner
            }
            .padding(.horizontal, AppSpacing.margin)
            .padding(.top, AppSpacing.spaceSm)
            .padding(.bottom, 120)
        }
        .background(AppColor.background.ignoresSafeArea())
    }
    
    // MARK: - Sections
    
    private var headerBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: "location.north.circle.fill")
                        .foregroundColor(AppColor.primary)
                    Text(viewModel.locationTitle)
                        .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                }
                
                Text(viewModel.calendarName)
                    .font(AppFont.interface(size: 12))
                    .foregroundColor(AppColor.tertiary)
            }
            
            Spacer()
            
            Button {
                // Settings sheet
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16))
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
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(AppColor.primary)
                    Text("Next Prayer • Solar Depression \(viewModel.solarAngleText)")
                        .font(AppFont.interfaceLabel(size: 12, weight: .semibold))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
                Spacer()
                Text("LIVE")
                    .font(AppFont.technicalMetric(size: 10, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.primaryContainer.opacity(0.5))
                    .clipShape(Capsule())
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fajr Prayer")
                        .font(AppFont.arabicHeading(size: 20))
                        .foregroundColor(AppColor.secondary)
                    Text("04:48 AM")
                        .font(AppFont.celestialDisplay(size: 38))
                        .foregroundColor(AppColor.onSurface)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 12))
                        Text(viewModel.countdownString)
                            .font(AppFont.celestialDisplay(size: 18))
                    }
                    .foregroundColor(AppColor.primary)
                    
                    Text("Remaining")
                        .font(AppFont.interfaceLabel(size: 11))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
            }
            
            Divider()
                .background(AppColor.hairlineBorder)
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                    Text("Adhan: \(viewModel.adhanReciter)")
                        .font(AppFont.interface(size: 12))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.tertiary)
                    Text(viewModel.iqamahText)
                        .font(AppFont.interfaceLabel(size: 12))
                        .foregroundColor(AppColor.tertiary)
                }
            }
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true, showEmeraldGlow: true)
    }
    
    private var prayerTrackerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            HStack {
                Text("Today's Tracker")
                    .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                
                Spacer()
                
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColor.primary)
                        .font(.system(size: 13))
                    Text("\(viewModel.completedCount) of \(viewModel.totalObligatoryCount) Completed")
                        .font(AppFont.interfaceLabel(size: 12, weight: .semibold))
                        .foregroundColor(AppColor.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColor.primaryContainer.opacity(0.3))
                .clipShape(Capsule())
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel.prayerRecords) { record in
                    HStack(spacing: AppSpacing.spaceMd) {
                        // Checkbox trigger
                        if record.kind.isObligatoryPrayer {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    viewModel.togglePrayerCompletion(kind: record.kind)
                                }
                            } label: {
                                Image(systemName: record.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(record.isCompleted ? AppColor.primary : AppColor.outline)
                                    .scaleEffect(record.isCompleted ? 1.05 : 1.0)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Image(systemName: "sun.horizon.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColor.tertiary)
                                .frame(width: 24)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(record.kind.rawValue)
                                    .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                                    .foregroundColor(AppColor.onSurface)
                                
                                Text(record.kind.arabicName)
                                    .font(AppFont.arabicHeading(size: 14))
                                    .foregroundColor(AppColor.secondary)
                            }
                            
                            Text(record.detailText)
                                .font(AppFont.interface(size: 11))
                                .foregroundColor(AppColor.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        Text(record.timeString)
                            .font(AppFont.technicalMetric(size: 14, weight: .semibold))
                            .foregroundColor(AppColor.onSurface)
                    }
                    .padding(.horizontal, AppSpacing.spaceMd)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .fill(record.isCompleted ? AppColor.surfaceContainer.opacity(0.8) : AppColor.surfaceContainerLow)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .strokeBorder(AppColor.hairlineBorder, lineWidth: 1)
                    }
                }
            }
        }
    }
    
    private var astronomicalUtilityGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            Text("Astronomical Instruments")
                .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                .foregroundColor(AppColor.secondary)
            
            HStack(spacing: 12) {
                // Qibla Compass Mini Instrument
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .strokeBorder(AppColor.primary.opacity(0.2), lineWidth: 2)
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "location.north.line.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColor.primary)
                            .rotationEffect(.degrees(viewModel.qiblaDegrees - viewModel.currentDeviceHeading))
                    }
                    
                    Text("\(Int(viewModel.qiblaDegrees))° W")
                        .font(AppFont.celestialDisplay(size: 16))
                        .foregroundColor(AppColor.onSurface)
                    
                    Text("Kaaba Qibla")
                        .font(AppFont.interfaceLabel(size: 11))
                        .foregroundColor(AppColor.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.spaceMd)
                .astrolabeGlass(cornerRadius: AppRadius.card)
                
                // Weekly Compliance Stats
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .strokeBorder(AppColor.surfaceContainerHighest, lineWidth: 5)
                            .frame(width: 64, height: 64)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(viewModel.weeklyComplianceRate) / 100.0)
                            .stroke(AppColor.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 64, height: 64)
                        
                        Text("\(viewModel.weeklyComplianceRate)%")
                            .font(AppFont.technicalMetric(size: 14, weight: .bold))
                            .foregroundColor(AppColor.primary)
                    }
                    
                    Text("Weekly Rate")
                        .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                    
                    Text("Consistent")
                        .font(AppFont.interfaceLabel(size: 11))
                        .foregroundColor(AppColor.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.spaceMd)
                .astrolabeGlass(cornerRadius: AppRadius.card)
            }
        }
    }
    
    private var ayahBanner: some View {
        VStack(spacing: 6) {
            Text("«إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا»")
                .font(AppFont.quranScripture(size: 18))
                .foregroundColor(AppColor.tertiary)
                .multilineTextAlignment(.center)
            
            Text("Surah An-Nisa • Ayah 103")
                .font(AppFont.interface(size: 11))
                .foregroundColor(AppColor.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
}
