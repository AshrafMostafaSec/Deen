import SwiftUI

public struct RadioView: View {
    @State private var viewModel = RadioViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.spaceLg) {
                    // Featured Cairo Quran Radio Hero
                    if let featured = viewModel.featuredStation {
                        featuredStationCard(featured)
                    }
                    
                    // Egyptian FM Radio Stations
                    egyptianFMStationsSection
                    
                    // Continuous Reciters 24/7 Channels
                    recitersChannelsSection
                }
                .padding(.horizontal, AppSpacing.margin)
                .padding(.top, AppSpacing.spaceSm)
                .padding(.bottom, 120)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Live Egyptian Radio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColor.outline)
                            .font(.system(size: 20))
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private func featuredStationCard(_ station: RadioStation) -> some View {
        let isCurrent = viewModel.isStationPlaying(station)
        
        return VStack(spacing: AppSpacing.spaceMd) {
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                    Text("FEATURED LIVE BROADCAST")
                        .font(AppFont.technicalMetric(size: 10, weight: .bold))
                        .foregroundColor(Color.red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.12))
                .clipShape(Capsule())
                
                Spacer()
                
                if let freq = station.frequencyMHz {
                    Text("\(String(format: "%.1f", freq)) FM")
                        .font(AppFont.technicalMetric(size: 12, weight: .bold))
                        .foregroundColor(AppColor.tertiary)
                }
            }
            
            HStack(spacing: AppSpacing.spaceMd) {
                ZStack {
                    Circle()
                        .fill(AppColor.primaryContainer)
                        .frame(width: 54, height: 54)
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 24))
                        .foregroundColor(AppColor.primary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(station.name)
                        .font(AppFont.arabicHeading(size: 16))
                        .foregroundColor(AppColor.onSurface)
                    
                    Text("Cairo, Egypt • Official Broadcast")
                        .font(AppFont.interface(size: 12))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
                
                Spacer()
                
                Button {
                    viewModel.playOrToggle(station: station)
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColor.primary)
                            .frame(width: 44, height: 44)
                        Image(systemName: isCurrent ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.onPrimary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true, showEmeraldGlow: true)
    }
    
    private var egyptianFMStationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            Text("Popular Egyptian FM Stations")
                .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                .foregroundColor(AppColor.onSurface)
            
            VStack(spacing: 8) {
                ForEach(viewModel.generalStations.filter { $0.category != .quran }) { station in
                    stationRow(station)
                }
            }
        }
    }
    
    private var recitersChannelsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            HStack {
                Text("24/7 Live Reciters")
                    .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Spacer()
                Text("Cairo Reciters")
                    .font(AppFont.interfaceLabel(size: 12))
                    .foregroundColor(AppColor.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel.generalStations.filter { $0.category == .quran }) { station in
                    stationRow(station)
                }
            }
        }
    }
    
    private func stationRow(_ station: RadioStation) -> some View {
        let isCurrent = viewModel.isStationPlaying(station)
        
        return HStack(spacing: AppSpacing.spaceMd) {
            ZStack {
                Circle()
                    .fill(AppColor.surfaceContainerHighest)
                    .frame(width: 40, height: 40)
                Image(systemName: station.category == .quran ? "book.fill" : "antenna.radiowaves.left.and.right")
                    .font(.system(size: 16))
                    .foregroundColor(isCurrent ? AppColor.primary : AppColor.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                
                Text(station.shortName ?? "Egyptian Radio")
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.onSurfaceVariant)
            }
            
            Spacer()
            
            Button {
                viewModel.playOrToggle(station: station)
            } label: {
                ZStack {
                    Circle()
                        .fill(isCurrent ? AppColor.primary : AppColor.surfaceContainerHigh)
                        .frame(width: 36, height: 36)
                    Image(systemName: isCurrent ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isCurrent ? AppColor.onPrimary : AppColor.primary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.spaceMd)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(isCurrent ? AppColor.surfaceContainer.opacity(0.8) : AppColor.surfaceContainerLow)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .strokeBorder(isCurrent ? AppColor.primary.opacity(0.4) : AppColor.hairlineBorder, lineWidth: 1)
        }
    }
}
